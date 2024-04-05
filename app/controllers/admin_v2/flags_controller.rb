module AdminV2
  class FlagsController < AdminV2::BaseController
    def index
      @pagy, @flags = pagy(Flag.by_status(params.fetch(:status, 'active')), items: 20)
    end

    def show
      @flag = Flag.find(params[:id])
    end

    def update
      @flag = Flag.find(params[:id])
      action = Flags::ActionFactory.for(params[:action_taken])
      result = action.perform(flag: @flag, admin_user: current_admin_user)

      if result.success?
        redirect_to admin_v2_flag_path(@flag), notice: result.message
      else
        redirect_to admin_v2_flag_path(@flag), alert: result.message
      end
    end
  end
end
