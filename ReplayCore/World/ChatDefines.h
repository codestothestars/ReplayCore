#ifndef __CHAT_DEFINES_H
#define __CHAT_DEFINES_H

namespace Vanilla
{
    enum ChatMsg
    {
        CHAT_MSG_ADDON                  = 0xFFFFFFFF,
        CHAT_MSG_SAY                    = 0x00,
        CHAT_MSG_PARTY                  = 0x01,
        CHAT_MSG_RAID                   = 0x02,
        CHAT_MSG_GUILD                  = 0x03,
        CHAT_MSG_OFFICER                = 0x04,
        CHAT_MSG_YELL                   = 0x05,
        CHAT_MSG_WHISPER                = 0x06,
        CHAT_MSG_WHISPER_INFORM         = 0x07,
        CHAT_MSG_EMOTE                  = 0x08,
        CHAT_MSG_TEXT_EMOTE             = 0x09,
        CHAT_MSG_SYSTEM                 = 0x0A,
        CHAT_MSG_MONSTER_SAY            = 0x0B,
        CHAT_MSG_MONSTER_YELL           = 0x0C,
        CHAT_MSG_MONSTER_EMOTE          = 0x0D,
        CHAT_MSG_CHANNEL                = 0x0E,
        CHAT_MSG_CHANNEL_JOIN           = 0x0F,
        CHAT_MSG_CHANNEL_LEAVE          = 0x10,
        CHAT_MSG_CHANNEL_LIST           = 0x11,
        CHAT_MSG_CHANNEL_NOTICE         = 0x12,
        CHAT_MSG_CHANNEL_NOTICE_USER    = 0x13,
        CHAT_MSG_AFK                    = 0x14,
        CHAT_MSG_DND                    = 0x15,
        CHAT_MSG_IGNORED                = 0x16,
        CHAT_MSG_SKILL                  = 0x17,
        CHAT_MSG_LOOT                   = 0x18,
        CHAT_MSG_BG_SYSTEM_NEUTRAL      = 0x52,
        CHAT_MSG_BG_SYSTEM_ALLIANCE     = 0x53,
        CHAT_MSG_BG_SYSTEM_HORDE        = 0x54,
        CHAT_MSG_RAID_LEADER            = 0x57,
        CHAT_MSG_RAID_WARNING           = 0x58,
        CHAT_MSG_BATTLEGROUND           = 0x5C,
        CHAT_MSG_BATTLEGROUND_LEADER    = 0x5D,

        // [-ZERO] Need find correct values
        // Valeurs trouvees (Nostalrius)
        CHAT_MSG_REPLY                  = 0x09,
        CHAT_MSG_MONSTER_PARTY          = 0x30, //0x0D, just selected some free random value for avoid duplicates with really existed values
        // 0x1A et non 0x31 (Nostalrius)
        CHAT_MSG_MONSTER_WHISPER        = 0x1A, //0x0F, just selected some free random value for avoid duplicates with really existed values
        //CHAT_MSG_MONEY                  = 0x1C,
        //CHAT_MSG_OPENING                = 0x1D,
        //CHAT_MSG_TRADESKILLS            = 0x1E,
        //CHAT_MSG_PET_INFO               = 0x1F,
        //CHAT_MSG_COMBAT_MISC_INFO       = 0x20,
        //CHAT_MSG_COMBAT_XP_GAIN         = 0x21,
        //CHAT_MSG_COMBAT_HONOR_GAIN      = 0x22,
        //CHAT_MSG_COMBAT_FACTION_CHANGE  = 0x23,
        CHAT_MSG_RAID_BOSS_WHISPER      = CHAT_MSG_MONSTER_WHISPER, // Et non 0x29. Y'a pas mieux.
        CHAT_MSG_RAID_BOSS_EMOTE        = 0x5A, // 0x5A et non 0x2A (Nostalrius)
        //CHAT_MSG_FILTERED               = 0x2B,
        //CHAT_MSG_RESTRICTED             = 0x2E,
    };
}

namespace TBC
{
    enum ChatMsg
    {
        CHAT_MSG_ADDON                  = 0xFFFFFFFF,
        CHAT_MSG_SYSTEM                 = 0x00,
        CHAT_MSG_SAY                    = 0x01,
        CHAT_MSG_PARTY                  = 0x02,
        CHAT_MSG_RAID                   = 0x03,
        CHAT_MSG_GUILD                  = 0x04,
        CHAT_MSG_OFFICER                = 0x05,
        CHAT_MSG_YELL                   = 0x06,
        CHAT_MSG_WHISPER                = 0x07,
        CHAT_MSG_WHISPER_FOREIGN        = 0x08,
        CHAT_MSG_WHISPER_INFORM         = 0x09,
        CHAT_MSG_EMOTE                  = 0x0A,
        CHAT_MSG_TEXT_EMOTE             = 0x0B,
        CHAT_MSG_MONSTER_SAY            = 0x0C,
        CHAT_MSG_MONSTER_PARTY          = 0x0D,
        CHAT_MSG_MONSTER_YELL           = 0x0E,
        CHAT_MSG_MONSTER_WHISPER        = 0x0F,
        CHAT_MSG_MONSTER_EMOTE          = 0x10,
        CHAT_MSG_CHANNEL                = 0x11,
        CHAT_MSG_CHANNEL_JOIN           = 0x12,
        CHAT_MSG_CHANNEL_LEAVE          = 0x13,
        CHAT_MSG_CHANNEL_LIST           = 0x14,
        CHAT_MSG_CHANNEL_NOTICE         = 0x15,
        CHAT_MSG_CHANNEL_NOTICE_USER    = 0x16,
        CHAT_MSG_AFK                    = 0x17,
        CHAT_MSG_DND                    = 0x18,
        CHAT_MSG_IGNORED                = 0x19,
        CHAT_MSG_SKILL                  = 0x1A,
        CHAT_MSG_LOOT                   = 0x1B,
        CHAT_MSG_MONEY                  = 0x1C,
        CHAT_MSG_OPENING                = 0x1D,
        CHAT_MSG_TRADESKILLS            = 0x1E,
        CHAT_MSG_PET_INFO               = 0x1F,
        CHAT_MSG_COMBAT_MISC_INFO       = 0x20,
        CHAT_MSG_COMBAT_XP_GAIN         = 0x21,
        CHAT_MSG_COMBAT_HONOR_GAIN      = 0x22,
        CHAT_MSG_COMBAT_FACTION_CHANGE  = 0x23,
        CHAT_MSG_BG_SYSTEM_NEUTRAL      = 0x24,
        CHAT_MSG_BG_SYSTEM_ALLIANCE     = 0x25,
        CHAT_MSG_BG_SYSTEM_HORDE        = 0x26,
        CHAT_MSG_RAID_LEADER            = 0x27,
        CHAT_MSG_RAID_WARNING           = 0x28,
        CHAT_MSG_RAID_BOSS_EMOTE        = 0x29,
        CHAT_MSG_RAID_BOSS_WHISPER      = 0x2A,
        CHAT_MSG_FILTERED               = 0x2B,
        CHAT_MSG_BATTLEGROUND           = 0x2C,
        CHAT_MSG_BATTLEGROUND_LEADER    = 0x2D,
        CHAT_MSG_RESTRICTED             = 0x2E,
    };
}

namespace WotLK
{
    enum ChatMsg
    {
        CHAT_MSG_ADDON                  = 0xFFFFFFFF,
        CHAT_MSG_SYSTEM                 = 0x00,
        CHAT_MSG_SAY                    = 0x01,
        CHAT_MSG_PARTY                  = 0x02,
        CHAT_MSG_RAID                   = 0x03,
        CHAT_MSG_GUILD                  = 0x04,
        CHAT_MSG_OFFICER                = 0x05,
        CHAT_MSG_YELL                   = 0x06,
        CHAT_MSG_WHISPER                = 0x07,
        CHAT_MSG_WHISPER_FOREIGN        = 0x08,
        CHAT_MSG_WHISPER_INFORM         = 0x09,
        CHAT_MSG_EMOTE                  = 0x0A,
        CHAT_MSG_TEXT_EMOTE             = 0x0B,
        CHAT_MSG_MONSTER_SAY            = 0x0C,
        CHAT_MSG_MONSTER_PARTY          = 0x0D,
        CHAT_MSG_MONSTER_YELL           = 0x0E,
        CHAT_MSG_MONSTER_WHISPER        = 0x0F,
        CHAT_MSG_MONSTER_EMOTE          = 0x10,
        CHAT_MSG_CHANNEL                = 0x11,
        CHAT_MSG_CHANNEL_JOIN           = 0x12,
        CHAT_MSG_CHANNEL_LEAVE          = 0x13,
        CHAT_MSG_CHANNEL_LIST           = 0x14,
        CHAT_MSG_CHANNEL_NOTICE         = 0x15,
        CHAT_MSG_CHANNEL_NOTICE_USER    = 0x16,
        CHAT_MSG_AFK                    = 0x17,
        CHAT_MSG_DND                    = 0x18,
        CHAT_MSG_IGNORED                = 0x19,
        CHAT_MSG_SKILL                  = 0x1A,
        CHAT_MSG_LOOT                   = 0x1B,
        CHAT_MSG_MONEY                  = 0x1C,
        CHAT_MSG_OPENING                = 0x1D,
        CHAT_MSG_TRADESKILLS            = 0x1E,
        CHAT_MSG_PET_INFO               = 0x1F,
        CHAT_MSG_COMBAT_MISC_INFO       = 0x20,
        CHAT_MSG_COMBAT_XP_GAIN         = 0x21,
        CHAT_MSG_COMBAT_HONOR_GAIN      = 0x22,
        CHAT_MSG_COMBAT_FACTION_CHANGE  = 0x23,
        CHAT_MSG_BG_SYSTEM_NEUTRAL      = 0x24,
        CHAT_MSG_BG_SYSTEM_ALLIANCE     = 0x25,
        CHAT_MSG_BG_SYSTEM_HORDE        = 0x26,
        CHAT_MSG_RAID_LEADER            = 0x27,
        CHAT_MSG_RAID_WARNING           = 0x28,
        CHAT_MSG_RAID_BOSS_EMOTE        = 0x29,
        CHAT_MSG_RAID_BOSS_WHISPER      = 0x2A,
        CHAT_MSG_FILTERED               = 0x2B,
        CHAT_MSG_BATTLEGROUND           = 0x2C,
        CHAT_MSG_BATTLEGROUND_LEADER    = 0x2D,
        CHAT_MSG_RESTRICTED             = 0x2E,
        CHAT_MSG_BNET                   = 0x2F,
        CHAT_MSG_ACHIEVEMENT            = 0x30,
        CHAT_MSG_GUILD_ACHIEVEMENT      = 0x31,
        CHAT_MSG_ARENA_POINTS           = 0x32,
        CHAT_MSG_PARTY_LEADER           = 0x33
    };
}

#endif