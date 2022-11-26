// 設定
// セーブ通知周期（分）
notify_period <- 1;

// プレイヤー
player <- null;
// 前回通知した日時
notified_at <- null;
prev_timestamp <- null;
// メッセージの座標
pos <- coord(0, 0);

function start(pl_num) {
    player = player_x(pl_num);
    notified_at = time();
    prev_timestamp = time();
    if("total_play_time" in persistent == false) {
        persistent.total_play_time <- 0;
    }
    local message = format(
        "AIが起動しました。 %d分ごとにセーブをするように通知します。", 
        notify_period
    );
    gui.add_message_at(player, message, pos);
}

function resume_game(pl_num) {
    start(pl_num);
}

function step() {
    if (player) {
        local now = time();
        if(notify_period > 0 && now - notified_at >= notify_period*60) {
            local message = format(
                "現在 %s、総プレイ時間 %.1f 時間です。そろそろセーブしましょう。", 
                get_date(),
                get_total_play_hours()
            );
            gui.add_message_at(player, message, pos);
            notified_at = now;
        }
        if(prev_timestamp < now) {
            persistent.total_play_time += now - prev_timestamp;
            prev_timestamp = now;
        }
    }
}

function get_date() {
    local d = date();
    // Y/m/d H:i
    return format("%d/%02d/%02d %02d:%02d", d.year, d.month, d.day, d.hour, d.min);
}

function get_total_play_hours() {
    if("total_play_time" in persistent) {
        return persistent.total_play_time.tofloat() / 3600.0;
    }
    persistent.total_play_time <- 0;
    return 0.0;
}