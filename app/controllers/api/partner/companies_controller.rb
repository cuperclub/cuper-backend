module Api
  module Partner
    class CompaniesController < Api::Partner::BaseController
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
        begin
          Company.transaction do
            company.save!
            Employee.create!(user: current_user, company: company, role: 'partner')
            if params[:plan_id]
              PlanCompany.create!(company: company, plan_id: params[:plan_id])
            end
            set_current_view(company.id)
          end

          render :company,
                status: :created,
                locals: { company: company }
        rescue ActiveRecord::RecordInvalid => error
          render json: error.record.errors,
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
        if Employee.exists?(user: @user, company: @company)
          render json: { error: "User already has a membership in this company" }, status: :conflict
          return
        end

        notification = UtilService.new(@user, current_user).notify_employee_request
        if notification.persisted?
          render "api/notifications/notification_request_employee",
                  locals: { notification:  notification }
          # CompanyMailer.invitation_employee_company(email, @company).deliver_now
        else
          render json: notification.errors,
                status: :unprocessable_entity
        end
      end

      def pending_requests_employee
        notifications = Notification.where(from_user: current_user,
                                            from_employee: current_user.my_employee,
                                            kind: "request_employee",
                                            status: "pending")
                                          .order(created_at: :desc)
        render "api/notifications/notifications_request_employee",
                locals: { notifications:  notifications }
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

      def set_current_view(company_id)
        setting = current_user.setting || Setting.new(user: current_user)
        setting.update!(current_company: company_id)
      end

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
        @company = find_partner_company
      end

      def find_user
        @user = User.find(params[:user_id])
      end
    end
  end
end
