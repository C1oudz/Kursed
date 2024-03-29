class VerificationCodesController < ApplicationController
  def new
    @verification_code = VerificationCode.new
  end

  def create
    @verification_code = VerificationCode.find_by(code: params[:verification_code][:code])
    if User.exists?(chat_id: @verification_code.chat_id)
      flash[:alert] = "Этот телеграм уже привязан к другому аккаунту"
      render :new
    elsif @verification_code && @verification_code.expires_at >= Time.now
      current_user.update(chat_id: @verification_code.chat_id)
      old_chat_id = current_user.chat_id
      VerificationCode.where(chat_id: old_chat_id).destroy_all if old_chat_id.present?
      redirect_to edit_user_registration_path, notice: 'Аккаунт успешно привязан к Telegram.'
    else
      flash[:alert] = 'Неверный код или истек срок его действия.'
      render :new
    end
  end
    def resetchatid
      if current_user.chat_id.present?
        current_user.update(chat_id: nil)
        redirect_to edit_user_registration_path, notice: 'Аккаунт успешно отвязан от Telegram.'
      else  
        redirect_to edit_user_registration_path, alert: 'Аккаунт не привязан к Telegram.'
      end
    end
end
