module Api
  module Partner
    class CompaniesController < BaseController
      before_action :authenticate_user!
      before_action :find_company, only: [:show,
                                          :update,
                                          :send_invitation_employee,
                                          :request_employee]
      before_action :find_user, only: [:request_employee]

      def_param_group :company do
        param :ruc, String,
              required: true
        param :business_name, String,
              required: true
        param :economic_activity, String,
              required: true
      end

      api :POST,
          "/partner/company",
          "Submit a company application. Response includes the errors if any."
      param_group :company
      example %q{
        "company":{
          "ruc":"5184135690",
          "business_name":"The Krusty krab.",
          "contributor_type":"Natural",
          "economic_activity":"Restaurant",
          "legal_representative":"Mr. Krabs",
          "logo":null,
          "slogan":"a cool slogan",
        }
      }

      def create
        company = Company.new(company_params)
        if company.save
          employee = Employee.new(
            user: current_user,
            company: company,
            role: 'partner'
          )
          employee.save
          render :company,
                status: :created,
                locals: { company: company }
        else
          render json: company.errors,
                status: :unprocessable_entity
        end
      end

      api :GET,
          "/partner/company",
          "Get my company"
      example %q{
        {
          "ruc":"5184135690",
          "business_name":"The Krusty krab.",
          "contributor_type":"Natural",
          "economic_activity":"Restaurant",
          "legal_representative":"Mr. Krabs",
          "logo":null,
          "slogan":"a cool slogan",
        }
      }

      def show
        render :company,
                status: :accepted,
                locals: { company: @company }
      end

      api :PUT,
          "/partner/company",
          "Update my company"
      example %q{
        "company":{
          "business_name":"The Krusty krab 2.",
          "slogan":"My new cool slogan",
        }
      }

      def update
        if @company.update(company_params)
          render :company,
                  status: :accepted,
                  locals: { company: @company }
        else
          render json: @company.errors,
                status: :unprocessable_entity
        end
      end

      def request_employee
        notification = UtilService.new(@user, current_user).notify_employee_request
        if notification.save
          render json: {status: :ok}, status: :ok
          # CompanyMailer.invitation_employee_company(email, @company).deliver_now
        else
          render json: notification.errors,
                status: :unprocessable_entity
        end
      end

      # def send_invitation_employee
      #   email = params[:email]
      #   if email
      #     CompanyMailer.invitation_employee_company(email, @company).deliver_now
      #     render json: {status: :ok}, status: :ok
      #   else
      #     render json: {emai: 'Invalid'},
      #           status: :unprocessable_entity
      #   end
      # end

      private

      def company_params
        params.permit(
          :ruc,
          :business_name,
          :contributor_type,
          :economic_activity,
          :legal_representative,
          :logo,
          :slogan,
          :category_id
        )
      end

      def find_company
        @company = Company.find(current_user.current_view_company_id)
      end

      def find_user
        @user = User.find(params[:user_id])
      end
    end
  end
end
