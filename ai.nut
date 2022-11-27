// 設定
// セーブ通知周期（分）
notify_period <- 15;

total_play_time_manager <- null;
play_time_notify_manager <- null;
message_sender <- null;
message_builder <- null;

function start(pl_num) {
    total_play_time_manager = TotalPlayTimeManager(persistent);
    play_time_notify_manager = PlayTimeNotifyManager(notify_period);
    message_sender = MessageSender(gui, pl_num);
    message_builder = MessageBuilder(total_play_time_manager, play_time_notify_manager);

    message_sender.send(message_builder.buildStartMessage());
}

function resume_game(pl_num) {
    start(pl_num);
}

function step() {
    if(total_play_time_manager) {
        total_play_time_manager.update();
    }
    if(play_time_notify_manager && play_time_notify_manager.shouldNotify()) {
        play_time_notify_manager.reset();
        message_sender.send(message_builder.buildSaveMessage());
    }
}

class TotalPlayTimeManager {
    persistent = null;
    prev = null;

    constructor(_persistent) {
        persistent = _persistent;
        if("total_play_time" in persistent == false) {
            persistent.total_play_time <- 0;
        }
        prev = time();
    }

    function update() {
        local now = time();
        if(prev < now) {
            persistent.total_play_time += now - prev;
            prev = now;
        }
    }

    function getTotalPlayTime() {
        if("total_play_time" in persistent) {
            return format(
                "%d時間%02d分%02d秒", 
                persistent.total_play_time / 3600, 
                (persistent.total_play_time % 3600)/ 60
                persistent.total_play_time % 60
            );
        }
        throw Error("total_play_time not found.");
    }
}

class PlayTimeNotifyManager {
    period = null;
    prev = null;

    constructor(_period) {
        period = _period;
        prev = time();
    }

    function shouldNotify() {
        return period > 0 && time() - prev >= period*60;
    }

    function reset() {
        prev = time();
    }
}

class MessageSender {
    gui = null;
    player = null;

    constructor(_gui, _pl_num) {
        gui = _gui;
        player = player_x(_pl_num);
    }

    function send(message) {
        gui.add_message_at(player, message, coord(0, 0));
    }
}

class MessageBuilder {
    total_play_time_manager = null;
    play_time_notify_manager = null;
    constructor(_total_play_time_manager, _play_time_notify_manager) {
        total_play_time_manager = _total_play_time_manager;
        play_time_notify_manager = _play_time_notify_manager;
    }

    function buildStartMessage() {
        return format(
            "現在%s、総プレイ時間は%sです。AIが%d分ごとにセーブをするように通知します。",
            getDate(),
            total_play_time_manager.getTotalPlayTime()
            play_time_notify_manager.period
        );
    }

    function buildSaveMessage() {
        return format(
            "現在%s、総プレイ時間は%sです。そろそろセーブしましょう。", 
            getDate(),
            total_play_time_manager.getTotalPlayTime()
        );
    }

    function getDate() {
        local d = date();
        return format("%d/%02d/%02d %02d:%02d", d.year, d.month, d.day, d.hour, d.min);
    }
}
