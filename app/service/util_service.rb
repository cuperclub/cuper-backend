class UtilService
  def initialize(client, current_user = nil)
    @client = client
    @current_user = current_user
  end

  def app_settings
    return AppSetting.last
  end

  def assign_promo_points
    app = app_settings
    if app && app.points_by_register > 0
      transaction_input = TransactionInput.new(
        user: @client,
        employee_id: app.main_employee_id,
        points: app.points_by_register
      )
      transaction_input.save
      create_and_send_notification!
    end
  end

  def notify_employee_request
    notification = Notification.new
    company = user_company
    notification.message = "La empresa: #{company.business_name} quiere registrarte como empleado"
    notification.kind = "request_employee"
    notification.from_user_id = @current_user.id
    notification.to_user_id = @client.id
    notification
  end

  private

  def create_and_send_notification!
    notification = Notification.new
    notification.message = "Cuper Club te ha recompensado con: #{app_settings.points_by_register} Pts. por registrarte 🎉🎉"
    notification.kind = "inital_points"
    notification.from_user_id = app_settings.main_employee_id
    notification.to_user_id = @client.id
    notification.save
  end

  def user_company
    Company.find(@current_user.current_view_company_id)
  end
end
