module Api
  module Partner
    class OfficesController < BaseController
      before_action :authenticate_user!

      api :GET,
          "/partner/offices",
          "Get all offices"
      example %q{
        "offices":[{
          "name": "Sucursal 1",
          "email":"sucursal_1@example.com",
          "address":"24 de Mayo",
        }]
      }

      def index
        offices = current_user.company.offices
        render :offices,
              status: :created,
              locals: { offices: offices }
      end

      def_param_group :office do
        param :name, String,
              required: true
        param :address, String,
              required: true
      end

      api :POST,
          "/partner/offices",
          "Submit a office entity. Response includes the errors if any."
      param_group :office
      example %q{
        "office":{
          "name": "Sucursal 2",
          "email":"sucursal_2@example.com",
          "address":"10 de Agosto",
        }
      }

      def create
        office = Office.new(office_params)
        if office.save
          render :office,
                status: :created,
                locals: { office: office }
        else
          render json: office.errors,
                status: :unprocessable_entity
        end
      end

      api :GET,
          "/partner/offices/:id",
          "Get a office"
      param :id, Integer, required: true
      example %q{
        "office":{
          "name": "Sucursal 1",
          "email":"sucursal_1@example.com",
          "address":"24 de Mayo",
        }
      }

      def show
        office = current_user.company.offices.find(params[:id])
        render :office,
                status: :accepted,
                locals: { office: office }
      end

      api :PUT,
      "/partner/offices/:id",
      "Edit a office"
      param :id, Integer, required: true
      example %q{
        "office":{
          "name":"Sucursalita",
          "email":"sucursalita@example.com",
        }
      }

      def update
        office = current_user.company.offices.find(params[:id])
        if office.update(office_params)
          render :office,
                  status: :accepted,
                  locals: { office: office }
        else
          render json: office.errors,
                status: :unprocessable_entity
        end
      end

      private

      def office_params
        params.require(:office).permit(
          :name,
          :address,
          :email,
          :company_id
        )
      end
    end
  end
end
