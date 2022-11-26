// 設定
// 通知周期（分）
notify_period <- 15;
// セーブ通知周期（分）
save_notify_period <- 30;

// プレイヤー
player <- null;
// 前回通知した日時
notified_at <- null;
save_notified_at <- null;
// メッセージの座標
pos <- coord(0, 0);

function start(pl_num) {
    player = player_x(pl_num);
    notified_at = time();
    save_notified_at = time();
    local message = format(
        "AIが起動しました。 %d分ごとに通知、%d分ごとにセーブをするように通知します。", 
        notify_period, 
        save_notify_period
    );
    gui.add_message_at(player, message, pos);
}

function resume_game(pl_num) {
    start(pl_num);
}

function step() {
    if (player) {
        local now = time();
        if(save_notify_period > 0 && now - save_notified_at >= save_notify_period*60) {
            local message = format("現在 %s です。そろそろセーブしましょう。", get_date());
            gui.add_message_at(player, message, pos);
            save_notified_at = now;
        }
        else if (notify_period > 0 && now - notified_at >= notify_period*60) {
            local message = format("現在 %s です。", get_date());
            gui.add_message_at(player, message, pos);
            notified_at = now;
        }
    }
}

function get_date() {
    local d = date();
    // Y/m/d H:i
    return format("%d/%02d/%02d %02d:%02d", d.year, d.month, d.day, d.hour, d.min);
}
