require "rails_helper"

RSpec.describe Portal::PortalController, type: :controller do
  describe "#current_intake" do
    let(:session_intake) { create :intake }
    let(:client) { create :client, intake: (create :intake) }

    before do
      session[:intake_id] = session_intake.id
    end

    context "when the client is authenticated" do
      before do
        sign_in client, scope: :client
      end

      it "is the clients intake" do
        expect(subject.current_intake).to eq client.intake
      end
    end

    context "when the client is not authenticated" do
      it "is nil" do
        expect(subject.current_intake).to eq nil
      end
    end
  end

  describe "#home" do
    it_behaves_like :a_get_action_for_authenticated_clients_only, action: :home

    context "as an authenticated client" do
      before do
        sign_in client
        allow(QuestionNavigation).to receive(:determine_current_step).and_return("/en/questions/asset-sale-loss")
      end

      context "with onboarding still to do" do
        let(:client) { create :client, intake: (create :intake, current_step: "/en/questions/additional-info") }

        before do
          create :tax_return, year: 2018, status: :intake_in_progress, client: client
          create :tax_return, year: 2017, status: :intake_in_progress, client: client
        end

        it "is ok" do
          get :home

          expect(response).to be_ok
        end

        it "exposes current_step and tax_returns are empty" do
          get :home

          expect(assigns(:current_step)).to eq "/en/questions/additional-info"
          expect(assigns(:tax_returns)).to eq []
        end

        context "with current_step nil" do
          let(:client) { create :client, intake: (create :intake) }
          it "backfills onto intake" do
            get :home
            expect(client.reload.intake.current_step).to eq "/en/questions/asset-sale-loss"
            expect(assigns(:current_step)).to eq "/en/questions/asset-sale-loss"
          end
        end
      end

      context "post-onboarding" do
        let(:client) { create :client, intake: (create :intake) }

        before do
          create :tax_return, year: 2018, status: :intake_in_progress, client: client
          create :tax_return, year: 2017, status: :prep_ready_for_prep, client: client
          create :tax_return, year: 2020, status: :intake_ready_for_call, client: client
        end

        it "is ok" do
          get :home

          expect(response).to be_ok
        end

        it "loads the client tax returns in desc order" do
          get :home

          expect(assigns(:tax_returns).map(&:year)).to eq [2020, 2018, 2017]
          expect(assigns(:current_step)).to eq nil
        end
      end
    end
  end
end
