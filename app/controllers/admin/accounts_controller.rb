# frozen_string_literal: true

class Admin::AccountsController < ApplicationController
  before_action :require_admin!
  before_action :set_account, except: :index

  layout 'admin'

  def index
    @accounts = Account.alphabetic.paginate(page: params[:page], per_page: 40)

    @accounts = @accounts.local                             if params[:local].present?
    @accounts = @accounts.remote                            if params[:remote].present?
    @accounts = @accounts.where(domain: params[:by_domain]) if params[:by_domain].present?
    @accounts = @accounts.silenced                          if params[:silenced].present?
    @accounts = @accounts.recent                            if params[:recent].present?
    @accounts = @accounts.suspended                         if params[:suspended].present?
  end

  def show; end

  def suspend
    Admin::SuspensionWorker.perform_async(@account.id)
    redirect_to admin_accounts_path
  end

  def unsuspend
    @account.update(suspended: false)
    redirect_to admin_accounts_path
  end

  def silence
    @account.update(silenced: true)
    redirect_to admin_accounts_path
  end

  def unsilence
    @account.update(silenced: false)
    redirect_to admin_accounts_path
  end

  private

  def set_account
    @account = Account.find(params[:id])
  end

  def account_params
    params.require(:account).permit(:silenced, :suspended)
  end
end
