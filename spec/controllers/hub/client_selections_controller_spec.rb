require "rails_helper"

RSpec.describe Hub::ClientSelectionsController do
  let(:organization) { create :organization }
  let(:user) { create :organization_lead_user, organization: organization }
  let(:clients) { create_list :client_with_intake_and_return, 3, vita_partner: organization, status: "file_efiled" }
  let(:client_selection) { create :client_selection, clients: clients }

  describe "#show" do
    let(:params) { { id: client_selection.id } }

    it_behaves_like :a_get_action_for_authenticated_users_only, action: :show

    context "as an authenticated user" do
      before { sign_in user }

      it "can see the right clients listed" do
        get :show, params: params

        expect(assigns(:clients)).to eq clients
      end

      context "as a user who does not have access to all the clients in the client selection" do
        let(:site) { create :site, parent_organization: organization }
        let(:clients_for_org) { create_list :client_with_intake_and_return, 2, vita_partner: organization, status: "file_efiled" }
        let(:clients_for_site) { create_list :client_with_intake_and_return, 2, vita_partner: site, status: "file_efiled" }
        let(:user) { create :site_coordinator_user, site: site }
        let(:clients) { clients_for_org + clients_for_site }

        it "only shows the allowed clients" do
          get :show, params: params

          expect(assigns(:clients)).to eq clients_for_site
        end
      end

      context "when rendering" do
        render_views

        it "is ok, adds a short message and points the search form to the client index" do
          get :show, params: params

          expect(response).to be_ok
          html = Nokogiri::HTML.parse(response.body)
          expect(html.at_css(".filter-form")["action"]).to eq hub_clients_path
          expect(response.body).to include "You are viewing 3 items from your saved search"
        end
      end
    end
  end
end
