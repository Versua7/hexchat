-- HexChat Lua script to scan for clones
-- This script checks each new nick and reports if they have connected previously with another nick.
-- It also checks for current clones.

hexchat.register("clones.lua", "0.1", "clones detection")

-- Table to store the list of connected users and their previous nicks
local user_history = {}

-- Function to log a message to HexChat
local function log_message(message)
    hexchat.print(message)
end

-- Event handler for new users joining the channel
local function on_join(word, eol, event)
    local nick = word[1]
    local host = hexchat.get_info("host")
    
    -- Check if the user has connected before with another nick
    if user_history[host] then
        if user_history[host] ~= nick then
            log_message(string.format("User %s has connected previously with nick %s", nick, user_history[host]))
        end
    end

    -- Store the current nick for the host
    user_history[host] = nick

    return hexchat.EAT_NONE
end

-- Event handler for users changing their nick
local function on_nick_change(word, eol, event)
    local old_nick = word[1]
    local new_nick = word[2]
    local host = hexchat.get_info("host")

    -- Update the nick for the host in the history table
    if user_history[host] then
        user_history[host] = new_nick
    end

    return hexchat.EAT_NONE
end

-- Event handler for checking current clones
local function on_check_clones(word, eol, event)
    local clones = {}
    
    for host, nick in pairs(user_history) do
        if not clones[nick] then
            clones[nick] = {}
        end
        table.insert(clones[nick], host)
    end

    log_message("Current clones:")
    for nick, hosts in pairs(clones) do
        if #hosts > 1 then
            log_message(string.format("Nick %s is used by hosts: %s", nick, table.concat(hosts, ", ")))
        end
    end

    return hexchat.EAT_ALL
end

-- Hook events
hexchat.hook_print("Join", on_join)
hexchat.hook_print("Change Nick", on_nick_change)
hexchat.hook_command("CHECKCLONES", on_check_clones)

-- Log a message to indicate the script has been loaded
log_message("Clone scanner script loaded.")
