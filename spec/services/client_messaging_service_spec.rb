require "rails_helper"

RSpec.describe ClientMessagingService do
  let(:intake) { create :intake, email_address: "client@example.com", sms_phone_number: "+14155551212" }
  let!(:client) { intake.client }
  let!(:user) { create :user }
  let(:expected_time) { DateTime.new(2020, 9, 9) }

  before do
    allow(DateTime).to receive(:now).and_return(expected_time)
    allow(ClientChannel).to receive(:broadcast_contact_record)
  end

  describe ".send_email", active_job: true do
    context "with a nil user" do
      it "raises an error" do
        expect do
          described_class.send_email(client, nil, "hello")
        end.to raise_error(ArgumentError, "User required")
      end
    end

    context "with an authenticated user" do
      it "saves a new outgoing email with the right info, enqueues email job, and broadcasts to ClientChannel" do
        expect do
          described_class.send_email(client, user, "hello")
        end.to change(OutgoingEmail, :count).by(1).and have_enqueued_job(SendOutgoingEmailJob)

        outgoing_email = OutgoingEmail.last
        expect(outgoing_email.subject).to eq("Update from GetYourRefund")
        expect(outgoing_email.body).to eq("hello")
        expect(outgoing_email.client).to eq client
        expect(outgoing_email.user).to eq user
        expect(outgoing_email.sent_at).to eq expected_time
        expect(outgoing_email.to).to eq client.email_address
        expect(ClientChannel).to have_received(:broadcast_contact_record).with(outgoing_email)
      end

      context "with blank body" do
        it "raises an error" do
          expect do
            described_class.send_email(client, user, " \n")
          end.to raise_error(ActiveRecord::RecordInvalid)
        end
      end

      context "with an attachment" do
        let(:attachment) { fixture_file_upload("attachments/test-pattern.png") }

        it "saves the attachment" do
          described_class.send_email(client, user, "hello", attachment: attachment)

          expect(OutgoingEmail.last.attachment).to be_present
        end
      end

      context "with a custom subject locale" do
        it "uses that locale" do
          described_class.send_email(client, user, "hola", subject_locale: "es")
          expect(OutgoingEmail.last.subject).to eq "Actualización de GetYourRefund"
        end
      end

      context "with a client whose locale differs from the current request" do
        before { intake.update(locale: "es") }

        it "uses the client locale" do
          described_class.send_email(client, user, "hola")
          expect(OutgoingEmail.last.subject).to eq "Actualización de GetYourRefund"
        end
      end
    end
  end

  describe ".send_email_to_all_signers", active_job: true do
    context "with a nil user" do
      it "raises an error" do
        expect do
          described_class.send_email_to_all_signers(client, nil, "hello")
        end.to raise_error(ArgumentError, "User required")
      end
    end

    context "with an authenticated user" do
      it "saves a new outgoing email with the right info, enqueues email job, and broadcasts to ClientChannel" do
        expect do
          described_class.send_email_to_all_signers(client, user, "hello")
        end.to change(OutgoingEmail, :count).by(1).and have_enqueued_job(SendOutgoingEmailJob)

        outgoing_email = OutgoingEmail.last
        expect(outgoing_email.subject).to eq("Update from GetYourRefund")
        expect(outgoing_email.body).to eq("hello")
        expect(outgoing_email.client).to eq client
        expect(outgoing_email.user).to eq user
        expect(outgoing_email.sent_at).to eq expected_time
        expect(outgoing_email.to).to eq client.email_address
        expect(ClientChannel).to have_received(:broadcast_contact_record).with(outgoing_email)
      end

      context "when the client is filing joint" do
        let(:intake) do
          create :intake, email_address: "client@example.com", spouse_email_address: "spouse@example.com", filing_joint: "yes"
        end

        it "includes the spouse email in the 'to' field" do
          described_class.send_email_to_all_signers(client, user, "hello")

          expect(OutgoingEmail.last.to).to eq "client@example.com,spouse@example.com"
        end
      end

      context "with an attachment" do
        let(:attachment) { fixture_file_upload("attachments/test-pattern.png") }

        it "saves the attachment" do
          described_class.send_email_to_all_signers(client, user, "hello", attachment: attachment)

          expect(OutgoingEmail.last.attachment).to be_present
        end
      end

      context "with a custom subject locale" do
        it "uses that locale" do
          described_class.send_email_to_all_signers(client, user, "hola", subject_locale: "es")
          expect(OutgoingEmail.last.subject).to eq "Actualización de GetYourRefund"
        end
      end

      context "with a client whose locale differs from the current request" do
        before { intake.update(locale: "es") }

        it "uses the client locale" do
          described_class.send_email_to_all_signers(client, user, "hola")
          expect(OutgoingEmail.last.subject).to eq "Actualización de GetYourRefund"
        end
      end
    end
  end

  describe ".send_system_email", active_job: true do
    it "saves a new outgoing email with the right info, enqueues email job, and broadcasts to ClientChannel" do
      expect do
        described_class.send_system_email(client, "hello", "subject")
      end.to change(OutgoingEmail, :count).by(1).and have_enqueued_job(SendOutgoingEmailJob)

      system_email = OutgoingEmail.last
      expect(system_email.subject).to eq("subject")
      expect(system_email.body).to eq("hello")
      expect(system_email.client).to eq client
      expect(system_email.sent_at).to eq expected_time
      expect(system_email.to).to eq client.email_address
      expect(ClientChannel).to have_received(:broadcast_contact_record).with(system_email)
    end

    context "with blank body" do
      it "raises an error" do
        expect do
          described_class.send_system_email(client, " \n", "subject")
        end.to raise_error(ActiveRecord::RecordInvalid)
      end
    end

    context "with blank subject" do
      it "raises an error" do
        expect do
          described_class.send_system_email(client, "body", " \n")
        end.to raise_error(ActiveRecord::RecordInvalid)
      end
    end
  end

  describe ".send_text_message", active_job: true do
    context "with a nil user" do
      it "raises an error" do
        expect do
          described_class.send_text_message(client, nil, "hello")
        end.to raise_error(ActiveRecord::RecordInvalid)
      end
    end

    context "with an authenticated user" do
      it "saves a new outgoing text message with the right info, enqueues job, and broadcasts to ClientChannel" do
        expect do
          described_class.send_text_message(client, user, "hello")
        end.to change(OutgoingTextMessage, :count).by(1)

        outgoing_text_message = OutgoingTextMessage.last
        expect(outgoing_text_message.body).to eq("hello")
        expect(outgoing_text_message.client).to eq client
        expect(outgoing_text_message.user).to eq user
        expect(outgoing_text_message.sent_at).to eq expected_time
        expect(outgoing_text_message.to_phone_number).to eq client.sms_phone_number
        expect(ClientChannel).to have_received(:broadcast_contact_record).with(outgoing_text_message)
        expect(SendOutgoingTextMessageJob).to have_been_enqueued.with(outgoing_text_message.id)
      end

      context "with blank body" do
        it "raises an error" do
          expect do
            described_class.send_text_message(client, user, " \n")
          end.to raise_error(ActiveRecord::RecordInvalid)
        end
      end
    end
  end

  describe ".send_system_text_message", active_job: true do
    it "saves a new system text message with the right info, enqueues job, and broadcasts to ClientChannel" do
      expect do
        described_class.send_system_text_message(client, "hello")
      end.to change(OutgoingTextMessage, :count).by(1)

      system_text_message = OutgoingTextMessage.last
      expect(system_text_message.body).to eq("hello")
      expect(system_text_message.client).to eq client
      expect(system_text_message.sent_at).to eq expected_time
      expect(system_text_message.to_phone_number).to eq client.sms_phone_number
      expect(ClientChannel).to have_received(:broadcast_contact_record).with(system_text_message)
      expect(SendOutgoingTextMessageJob).to have_been_enqueued.with(system_text_message.id)
    end
  end

  describe ".send_message_to_all_opted_in_contact_methods", active_job: true do
    let(:body) { "heyo" }
    let(:user) { create :user }

    context "when the client has not opted in to anything" do
      let(:intake) { create :intake, sms_notification_opt_in: "no", email_notification_opt_in: "no" }

      it "returns a hash with nil for both message record types" do
        expect(described_class.send_message_to_all_opted_in_contact_methods(client, user, body))
          .to eq({
                   outgoing_email: nil,
                   outgoing_text_message: nil
                 })
      end
    end

    context "when client has opted in to email and has an email_address" do
      let(:intake) { create :intake, sms_notification_opt_in: "no", email_notification_opt_in: "yes", email_address: "something@example.com" }
      let(:outgoing_email) { build :outgoing_email }
      before do
        allow(described_class).to receive(:send_email).and_return(outgoing_email)
      end

      it "returns a hash with the output of send_email as the value for outgoing_email" do
        expect(described_class.send_message_to_all_opted_in_contact_methods(client, user, body))
          .to eq({
                   outgoing_email: outgoing_email,
                   outgoing_text_message: nil
                 })
        expect(described_class).to have_received(:send_email).with(client, user, body)
      end
    end

    context "when the client has opted into sms and has an sms_phone_number" do
      let(:intake) { create :intake, sms_notification_opt_in: "yes", email_notification_opt_in: "no", sms_phone_number: "+14155551212" }
      let(:outgoing_text_message) { build :outgoing_text_message }
      before do
        allow(described_class).to receive(:send_text_message).and_return(outgoing_text_message)
      end

      it "returns a hash with the output of send_text_message as the value for outgoing_text_message" do
        expect(described_class.send_message_to_all_opted_in_contact_methods(client, user, body))
          .to eq({
                   outgoing_text_message: outgoing_text_message,
                   outgoing_email: nil
                 })
        expect(described_class).to have_received(:send_text_message).with(client, user, body)
      end
    end

    context "when the client has opted into one contact method but lacks the contact info" do
      let(:intake) { create :intake, sms_notification_opt_in: "yes", email_notification_opt_in: "no", sms_phone_number: nil }

      it "returns a hash with nil as the value for contact record" do
        expect(described_class.send_message_to_all_opted_in_contact_methods(client, user, body))
          .to eq({
                   outgoing_text_message: nil,
                   outgoing_email: nil
                 })
      end
    end

    context "when the client prefers both and has all the contact info" do
      let(:intake) { create :intake, sms_notification_opt_in: "yes", email_notification_opt_in: "yes", sms_phone_number: "+14155551212", email_address: "client@example.com" }
      let(:outgoing_email) { build :outgoing_email }
      let(:outgoing_text_message) { build :outgoing_text_message }
      before do
        allow(described_class).to receive(:send_email).and_return(outgoing_email)
        allow(described_class).to receive(:send_text_message).and_return(outgoing_text_message)
      end

      it "returns a hash containing all contact records" do
        expect(described_class.send_message_to_all_opted_in_contact_methods(client, user, body))
          .to eq({
                   outgoing_text_message: outgoing_text_message,
                   outgoing_email: outgoing_email
                 })
        expect(described_class).to have_received(:send_email).with(client, user, body)
        expect(described_class).to have_received(:send_text_message).with(client, user, body)
      end
    end

    context "when the client prefers both but only has contact info for one" do
      let(:intake) { create :intake, sms_notification_opt_in: "yes", email_notification_opt_in: "yes", sms_phone_number: nil, email_address: "client@example.com" }
      let(:outgoing_email) { build :outgoing_email }
      before do
        allow(described_class).to receive(:send_email).and_return(outgoing_email)
      end

      it "returns a hash containing with only one contact record for the fully usable method" do
        expect(described_class.send_message_to_all_opted_in_contact_methods(client, user, body))
          .to eq({
                   outgoing_text_message: nil,
                   outgoing_email: outgoing_email
                 })
        expect(described_class).to have_received(:send_email).with(client, user, body)
      end
    end
  end

  describe ".send_system_message_to_all_opted_in_contact_methods", active_job: true do
    let(:email_body) { "heyo" }
    let(:sms_body) { "hi!" }
    let(:subject) { "email subject" }

    context "when the client has not opted in to anything" do
      let(:intake) { create :intake, sms_notification_opt_in: "no", email_notification_opt_in: "no" }

      it "returns a hash with nil for both message record types" do
        expect(described_class.send_system_message_to_all_opted_in_contact_methods(client, email_body: email_body, sms_body: sms_body, subject: subject))
          .to eq({
                   outgoing_email: nil,
                   outgoing_text_message: nil
                 })
      end
    end

    context "when client has opted in to email and has an email_address" do
      let(:intake) { create :intake, sms_notification_opt_in: "no", email_notification_opt_in: "yes", email_address: "something@example.com" }
      let(:outgoing_email) { build :outgoing_email }
      before do
        allow(described_class).to receive(:send_system_email).and_return(outgoing_email)
      end

      it "returns a hash with the output of send_email as the value for outgoing_email" do
        expect(described_class.send_system_message_to_all_opted_in_contact_methods(client, email_body: email_body, subject: subject))
          .to eq({
                   outgoing_email: outgoing_email,
                   outgoing_text_message: nil
                 })
        expect(described_class).to have_received(:send_system_email).with(client, email_body, subject)
      end
    end

    context "when the client has opted into sms and has an sms_phone_number" do
      let(:intake) { create :intake, sms_notification_opt_in: "yes", email_notification_opt_in: "no", sms_phone_number: "+14155551212" }
      let(:outgoing_text_message) { build :outgoing_text_message }
      before do
        allow(described_class).to receive(:send_system_text_message).and_return(outgoing_text_message)
      end

      it "returns a hash with the output of send_text_message as the value for outgoing_text_message" do
        expect(described_class.send_system_message_to_all_opted_in_contact_methods(client, sms_body: sms_body))
          .to eq({
                   outgoing_text_message: outgoing_text_message,
                   outgoing_email: nil
                 })
        expect(described_class).to have_received(:send_system_text_message).with(client, sms_body)
      end
    end

    context "when the client has opted into one contact method but lacks the contact info" do
      let(:intake) { create :intake, sms_notification_opt_in: "yes", email_notification_opt_in: "no", sms_phone_number: nil }

      it "returns a hash with nil as the value for contact record" do
        expect(described_class.send_system_message_to_all_opted_in_contact_methods(client, email_body: email_body, sms_body: sms_body, subject: subject))
          .to eq({
                   outgoing_text_message: nil,
                   outgoing_email: nil
                 })
      end
    end

    context "when the client prefers both and has all the contact info" do
      let(:intake) { create :intake, sms_notification_opt_in: "yes", email_notification_opt_in: "yes", sms_phone_number: "+14155551212", email_address: "client@example.com" }
      let(:outgoing_email) { build :outgoing_email }
      let(:outgoing_text_message) { build :outgoing_text_message }
      before do
        allow(described_class).to receive(:send_system_email).and_return(outgoing_email)
        allow(described_class).to receive(:send_system_text_message).and_return(outgoing_text_message)
      end

      it "returns a hash containing all contact records" do
        expect(described_class.send_system_message_to_all_opted_in_contact_methods(client, email_body: email_body, sms_body: sms_body, subject: subject))
          .to eq({
                   outgoing_text_message: outgoing_text_message,
                   outgoing_email: outgoing_email
                 })
        expect(described_class).to have_received(:send_system_email).with(client, email_body, subject)
        expect(described_class).to have_received(:send_system_text_message).with(client, sms_body)
      end
    end

    context "when the client prefers both but only has contact info for one" do
      let(:intake) { create :intake, sms_notification_opt_in: "yes", email_notification_opt_in: "yes", sms_phone_number: nil, email_address: "client@example.com" }
      let(:outgoing_email) { build :outgoing_email }
      before do
        allow(described_class).to receive(:send_system_email).and_return(outgoing_email)
      end

      it "returns a hash containing with only one contact record for the fully usable method" do
        expect(described_class.send_system_message_to_all_opted_in_contact_methods(client, email_body: email_body, sms_body: sms_body, subject: subject))
          .to eq({
                   outgoing_text_message: nil,
                   outgoing_email: outgoing_email
                 })
        expect(described_class).to have_received(:send_system_email).with(client, email_body, subject)
      end
    end
  end

  describe ".contact_methods" do
    context "with a client opted-in to email" do
      let(:client) { create(:intake, email_address: email_address, email_notification_opt_in: "yes").client }
      context "when the client has an email address" do
        let(:email_address) { "example@example.com" }

        it "returns the email address" do
          expect(described_class.contact_methods(client)).to eq({ email: "example@example.com" })
        end
      end

      context "when the client has no email address" do
        let(:email_address) { nil }

        it "returns an empty hash" do
          expect(described_class.contact_methods(client)).to eq({})
        end
      end
    end

    context "with a client opted-in to nothing" do
      let(:client) { create(:intake).client }

      it "returns an empty hash" do
        expect(described_class.contact_methods(client)).to eq({})
      end
    end

    context "with a client opted-in to sms" do
      let(:client) { create(:intake, sms_phone_number: sms_phone_number, sms_notification_opt_in: "yes").client }
      context "when the client has an sms number" do
        let(:sms_phone_number) { "+14155551212" }

        it "returns the number" do
          expect(described_class.contact_methods(client)).to eq({ sms_phone_number: "+14155551212" })
        end
      end

      context "when the client has no sms number" do
        let(:sms_phone_number) { nil }

        it "returns an empty hash" do
          expect(described_class.contact_methods(client)).to eq({})
        end
      end
    end

    context "with a client opted-in to both" do
      let(:client) { create(:intake, email_address: email_address, sms_phone_number: sms_phone_number, email_notification_opt_in: "yes", sms_notification_opt_in: "yes").client }
      context "when the client has an sms number and email address" do
        let(:email_address) { "example@example.com" }
        let(:sms_phone_number) { "+14155551212" }

        it "returns both, email address first" do
          contact_methods = described_class.contact_methods(client)
          expect(contact_methods).to eq({ email: "example@example.com", sms_phone_number: "+14155551212" })
          expect(contact_methods.keys.first).to eq(:email)
        end
      end
    end
  end
end
