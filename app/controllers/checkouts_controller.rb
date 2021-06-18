class CheckoutsController < ApplicationController
  before_action :authenticate_user!

  def show
    current_user.processor = :stripe
    current_user.customer

    @checkout_session_annual = current_user.payment_processor.checkout(
      mode: "subscription",
      line_items: "price_1IviMq2NAuZraGpQvHWbPDZ1"
    )
  end
end
