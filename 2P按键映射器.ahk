#Requires AutoHotkey v2.0
#SingleInstance Force
SendMode("Input")
SetKeyDelay(-1, -1)

; ============================================================
;  2P 按键映射器   —— 在「客户端」那台电脑运行
;  （客户端 = 用 Moonlight 看画面、按键被传回主机的那台）
;
;  热键：
;    Ctrl + Alt + 1 ~ 9   切换预设
;    Ctrl + Alt + 0       关闭映射（这台电脑改当主机时按这个）
;    Ctrl + Alt + R       重新加载（改完下面预设表后按）
;
;  读法：左边的键 = 你实际按的；右边的键 = 游戏里 2P 的按键
;        右边的键必须和游戏「设置 → 按键设置」里 2P 的键一致
; ============================================================

global Presets := Map(

    ; 预设 1：造梦西游3 —— WASD 移动 → 方向键；其余 9 键 → 小键盘 / 主键盘 0
    ;（完整键位对照见 README.md 的表格）
    1, {name: "造梦西游3（WASD→方向键，9 个功能键）", map: Map(
        "w", "Up",      "a", "Left",    "s", "Down",    "d", "Right",
        "j", "Numpad1", "k", "Numpad2", "h", "Numpad7", "u", "Numpad3",
        "i", "Numpad4", "o", "Numpad5", "y", "Numpad6", "l", "Numpad8",
        "Space", "0"
    )},

    ; 预设 2：街机 / 格斗类，2P 常用方向键 + 小键盘 1~4
    2, {name: "街机/格斗（WASD→方向键，JKLU→小键盘1234）", map: Map(
        "w", "Up",      "a", "Left",    "s", "Down",    "d", "Right",
        "j", "Numpad1", "k", "Numpad2", "l", "Numpad3", "u", "Numpad4"
    )},

    ; 预设 3：右手布局，IJKL 当移动键
    3, {name: "右手布局（IJKL→方向键）", map: Map(
        "i", "Up", "j", "Left", "k", "Down", "l", "Right"
    )},

    ; 预设 4：只要移动，攻击跳跃不映射
    4, {name: "仅移动（WASD→方向键）", map: Map(
        "w", "Up", "a", "Left", "s", "Down", "d", "Right"
    )},

    ; 预设 5：自定义空位 —— 照上面格式自己加，去掉行首的分号即可
    5, {name: "自定义（请自己改这一行）", map: Map(
        "w", "Up", "a", "Left", "s", "Down", "d", "Right"
        ; , "j", "1", "k", "2"     ; ← 攻击/跳跃示例：按 J 发主键盘 1，按 K 发主键盘 2
    )}
)

; ---------------- 以下逻辑不用改 ----------------

global BoundKeys := []

ApplyPreset(n) {
    global BoundKeys
    for k in BoundKeys
        try Hotkey("*" k, "Off")
    BoundKeys := []

    if (n = 0) {
        Notify("按键映射：已关闭")
        return
    }
    if !Presets.Has(n) {
        Notify("没有编号 " n " 的预设")
        return
    }
    p := Presets[n]
    for src, dst in p.map {
        try {
            Hotkey("*" src, MakeRemap(src, dst), "On")
            BoundKeys.Push(src)
        } catch {
            Notify("绑定失败：" src)
        }
    }
    Notify("已切换预设 " n "`n" p.name)
}

MakeRemap(src, dst) {
    fn(*) {
        Send("{" dst " down}")
        KeyWait(src)
        Send("{" dst " up}")
    }
    return fn
}

MakePresetFn(n) {
    fn(*) {
        ApplyPreset(n)
    }
    return fn
}

Notify(text) {
    ToolTip(text)
    SetTimer(ClearTip, -2000)
}
ClearTip() {
    ToolTip()
}

MakeReload(*) {
    Reload()
}

; 注册切换热键
Loop 9
    Hotkey("^!" A_Index, MakePresetFn(A_Index))
Hotkey("^!0", MakePresetFn(0))
Hotkey("^!r", MakeReload)

; 启动时默认应用预设 1
SetTimer(() => ApplyPreset(1), -300)
