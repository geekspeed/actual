module PaymentsHelper

  def payment_status(payment)
    if payment.success?
      "<span class=\"label label-success\">Success</span>".html_safe
    else
      "<span class=\"label label-danger\">Failed</span>".html_safe
    end
  end

  def currency_format(object, amount)
    [ISO4217::Currency.from_code(object.currency).try(:symbol), amount].compact.join(" ")
  end

end
