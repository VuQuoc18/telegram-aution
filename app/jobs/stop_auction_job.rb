class StopAuctionJob < ApplicationJob
  queue_as :default

  def perform(auction, chat_id, receiver, update)
    auction.participants.map do |participant|
      Telegram.bot.send_message chat_id: participant['id'],
      text: "#{participant['first_name']}, аукцион по лоту: '#{auction.name}' окончен"
    end
    send_history(auction, receiver)
    auction.update!(active: false)
    remove_buttons(chat_id, update)
    Telegram.bot.send_message chat_id: receiver, text: "Аукцион по лоту #{auction.name} успешно закрыт"
  end

  private

  def send_history(auction, receiver)
    auction.history.last(5).each do |winner|
      if winner['username']
        Telegram.bot.send_message chat_id: receiver, text: "#{winner['full_name']}, "\
        "http://t.me/#{winner['username']} - ставка #{winner['bet']}\n"
      else
        Telegram.bot.send_message chat_id: receiver, text: "#{winner['full_name']} - ставка #{winner['bet']}\n"
      end
    end
  end

  def remove_buttons(chat_id, update)
    Telegram.bot.edit_message_reply_markup(chat_id: chat_id,
      message_id: update['callback_query']['message']['message_id'])
  end
end