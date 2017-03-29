class BannedUsersController < ApplicationController
  before_action :set_banned_user, only: :destroy

  def index
    @banned_users = BannedUser.all
  end

  def create
    @banned_user = BannedUser.create(banned_user_params)
  end

  def destroy
    @banned_user.destroy
  end

  private

  def banned_user_params
    params.require(:banned_user).permit(:user_id, :first_name, :last_name)
  end

  def set_banned_user
    @banned_user = BannedUser.find(params[:id])
  end
end
