/*
* This program is free software; you can redistribute it and/or modify
* it under the terms of the GNU General Public License as published by
* the Free Software Foundation; either version 2 of the License, or
* (at your option) any later version.
*
* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
* GNU General Public License for more details.
*
* You should have received a copy of the GNU General Public License
* along with this program; if not, write to the Free Software
* Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
*/

#ifndef MANGOS_H_CLASSICDEFINES
#define MANGOS_H_CLASSICDEFINES

#include "../Defines/Common.h"
#include "UnitDefines.h"
#include "MovementDefines.h"
#include "ChatDefines.h"
#include <string>

enum ClassicWeatherState : uint32
{
    WEATHER_STATE_FINE              = 0,
    WEATHER_STATE_FOG               = 1,
    WEATHER_STATE_DRIZZLE           = 2,
    WEATHER_STATE_LIGHT_RAIN        = 3,
    WEATHER_STATE_MEDIUM_RAIN       = 4,
    WEATHER_STATE_HEAVY_RAIN        = 5,
    WEATHER_STATE_LIGHT_SNOW        = 6,
    WEATHER_STATE_MEDIUM_SNOW       = 7,
    WEATHER_STATE_HEAVY_SNOW        = 8,
    WEATHER_STATE_LIGHT_SANDSTORM   = 22,
    WEATHER_STATE_MEDIUM_SANDSTORM  = 41,
    WEATHER_STATE_HEAVY_SANDSTORM   = 42,
    WEATHER_STATE_THUNDERS          = 86,
    WEATHER_STATE_BLACKRAIN         = 90,
    WEATHER_STATE_BLACKSNOW         = 106
};

enum ClassicNPCFlags : uint32
{
    CLASSIC_UNIT_NPC_FLAG_GOSSIP                = 0x00000001,     // 100%
    CLASSIC_UNIT_NPC_FLAG_QUESTGIVER            = 0x00000002,     // 100%
    CLASSIC_UNIT_NPC_FLAG_UNK1                  = 0x00000004,
    CLASSIC_UNIT_NPC_FLAG_UNK2                  = 0x00000008,
    CLASSIC_UNIT_NPC_FLAG_TRAINER               = 0x00000010,     // 100%
    CLASSIC_UNIT_NPC_FLAG_TRAINER_CLASS         = 0x00000020,     // 100%
    CLASSIC_UNIT_NPC_FLAG_TRAINER_PROFESSION    = 0x00000040,     // 100%
    CLASSIC_UNIT_NPC_FLAG_VENDOR                = 0x00000080,     // 100%
    CLASSIC_UNIT_NPC_FLAG_VENDOR_AMMO           = 0x00000100,     // 100%, general goods vendor
    CLASSIC_UNIT_NPC_FLAG_VENDOR_FOOD           = 0x00000200,     // 100%
    CLASSIC_UNIT_NPC_FLAG_VENDOR_POISON         = 0x00000400,     // guessed
    CLASSIC_UNIT_NPC_FLAG_VENDOR_REAGENT        = 0x00000800,     // 100%
    CLASSIC_UNIT_NPC_FLAG_REPAIR                = 0x00001000,     // 100%
    CLASSIC_UNIT_NPC_FLAG_FLIGHTMASTER          = 0x00002000,     // 100%
    CLASSIC_UNIT_NPC_FLAG_SPIRITHEALER          = 0x00004000,     // guessed
    CLASSIC_UNIT_NPC_FLAG_SPIRITGUIDE           = 0x00008000,     // guessed
    CLASSIC_UNIT_NPC_FLAG_INNKEEPER             = 0x00010000,     // 100%
    CLASSIC_UNIT_NPC_FLAG_BANKER                = 0x00020000,     // 100%
    CLASSIC_UNIT_NPC_FLAG_PETITIONER            = 0x00040000,     // 100% 0xC0000 = guild petitions, 0x40000 = arena team petitions
    CLASSIC_UNIT_NPC_FLAG_TABARDDESIGNER        = 0x00080000,     // 100%
    CLASSIC_UNIT_NPC_FLAG_BATTLEMASTER          = 0x00100000,     // 100%
    CLASSIC_UNIT_NPC_FLAG_AUCTIONEER            = 0x00200000,     // 100%
    CLASSIC_UNIT_NPC_FLAG_STABLEMASTER          = 0x00400000,     // 100%
    CLASSIC_UNIT_NPC_FLAG_GUILD_BANKER          = 0x00800000,     //
    CLASSIC_UNIT_NPC_FLAG_SPELLCLICK            = 0x01000000,     //
    CLASSIC_UNIT_NPC_FLAG_PLAYER_VEHICLE        = 0x02000000,     // players with mounts that have vehicle data should have it set
    CLASSIC_UNIT_NPC_FLAG_MAILBOX               = 0x04000000,     // mailbox
    CLASSIC_UNIT_NPC_FLAG_ARTIFACT_POWER_RESPEC = 0x08000000,     // artifact powers reset
    CLASSIC_UNIT_NPC_FLAG_TRANSMOGRIFIER        = 0x10000000,     // transmogrification
    CLASSIC_UNIT_NPC_FLAG_VAULTKEEPER           = 0x20000000,     // void storage
    CLASSIC_UNIT_NPC_FLAG_WILD_BATTLE_PET       = 0x40000000,     // Pet that player can fight (Battle Pet)
    CLASSIC_UNIT_NPC_FLAG_BLACK_MARKET          = 0x80000000,     // black market
    CLASSIC_MAX_NPC_FLAGS                       = 32
};

inline uint32 ConvertClassicNpcFlagToVanilla(uint32 flag)
{
    switch (flag)
    {
        case CLASSIC_UNIT_NPC_FLAG_GOSSIP:
            return Vanilla::UNIT_NPC_FLAG_GOSSIP;
        case CLASSIC_UNIT_NPC_FLAG_QUESTGIVER:
            return Vanilla::UNIT_NPC_FLAG_QUESTGIVER;
        case CLASSIC_UNIT_NPC_FLAG_TRAINER:
        case CLASSIC_UNIT_NPC_FLAG_TRAINER_CLASS:
        case CLASSIC_UNIT_NPC_FLAG_TRAINER_PROFESSION:
            return Vanilla::UNIT_NPC_FLAG_TRAINER;
        case CLASSIC_UNIT_NPC_FLAG_VENDOR:
        case CLASSIC_UNIT_NPC_FLAG_VENDOR_AMMO:
        case CLASSIC_UNIT_NPC_FLAG_VENDOR_FOOD:
        case CLASSIC_UNIT_NPC_FLAG_VENDOR_POISON:
        case CLASSIC_UNIT_NPC_FLAG_VENDOR_REAGENT:
            return Vanilla::UNIT_NPC_FLAG_VENDOR;
        case CLASSIC_UNIT_NPC_FLAG_REPAIR:
            return Vanilla::UNIT_NPC_FLAG_REPAIR;
        case CLASSIC_UNIT_NPC_FLAG_FLIGHTMASTER:
            return Vanilla::UNIT_NPC_FLAG_FLIGHTMASTER;
        case CLASSIC_UNIT_NPC_FLAG_SPIRITHEALER:
            return Vanilla::UNIT_NPC_FLAG_SPIRITHEALER;
        case CLASSIC_UNIT_NPC_FLAG_SPIRITGUIDE:
            return Vanilla::UNIT_NPC_FLAG_SPIRITGUIDE;
        case CLASSIC_UNIT_NPC_FLAG_INNKEEPER:
            return Vanilla::UNIT_NPC_FLAG_INNKEEPER;
        case CLASSIC_UNIT_NPC_FLAG_BANKER:
            return Vanilla::UNIT_NPC_FLAG_BANKER;
        case CLASSIC_UNIT_NPC_FLAG_PETITIONER:
            return Vanilla::UNIT_NPC_FLAG_PETITIONER;
        case CLASSIC_UNIT_NPC_FLAG_TABARDDESIGNER:
            return Vanilla::UNIT_NPC_FLAG_TABARDDESIGNER;
        case CLASSIC_UNIT_NPC_FLAG_BATTLEMASTER:
            return Vanilla::UNIT_NPC_FLAG_BATTLEMASTER;
        case CLASSIC_UNIT_NPC_FLAG_AUCTIONEER:
            return Vanilla::UNIT_NPC_FLAG_AUCTIONEER;
        case CLASSIC_UNIT_NPC_FLAG_STABLEMASTER:
            return Vanilla::UNIT_NPC_FLAG_STABLEMASTER;
    }
    return 0;
}

inline uint32 ConvertClassicNpcFlagToTBC(uint32 flag)
{
    switch (flag)
    {
        case CLASSIC_UNIT_NPC_FLAG_GOSSIP:
            return TBC::UNIT_NPC_FLAG_GOSSIP;
        case CLASSIC_UNIT_NPC_FLAG_QUESTGIVER:
            return TBC::UNIT_NPC_FLAG_QUESTGIVER;
        case CLASSIC_UNIT_NPC_FLAG_TRAINER:
            return TBC::UNIT_NPC_FLAG_TRAINER;
        case CLASSIC_UNIT_NPC_FLAG_TRAINER_CLASS:
            return TBC::UNIT_NPC_FLAG_TRAINER_CLASS;
        case CLASSIC_UNIT_NPC_FLAG_TRAINER_PROFESSION:
            return TBC::UNIT_NPC_FLAG_TRAINER_PROFESSION;
        case CLASSIC_UNIT_NPC_FLAG_VENDOR:
            return TBC::UNIT_NPC_FLAG_VENDOR;
        case CLASSIC_UNIT_NPC_FLAG_VENDOR_AMMO:
            return TBC::UNIT_NPC_FLAG_VENDOR_AMMO;
        case CLASSIC_UNIT_NPC_FLAG_VENDOR_FOOD:
            return TBC::UNIT_NPC_FLAG_VENDOR_FOOD;
        case CLASSIC_UNIT_NPC_FLAG_VENDOR_POISON:
            return TBC::UNIT_NPC_FLAG_VENDOR_POISON;
        case CLASSIC_UNIT_NPC_FLAG_VENDOR_REAGENT:
            return TBC::UNIT_NPC_FLAG_VENDOR_REAGENT;
        case CLASSIC_UNIT_NPC_FLAG_REPAIR:
            return TBC::UNIT_NPC_FLAG_REPAIR;
        case CLASSIC_UNIT_NPC_FLAG_FLIGHTMASTER:
            return TBC::UNIT_NPC_FLAG_FLIGHTMASTER;
        case CLASSIC_UNIT_NPC_FLAG_SPIRITHEALER:
            return TBC::UNIT_NPC_FLAG_SPIRITHEALER;
        case CLASSIC_UNIT_NPC_FLAG_SPIRITGUIDE:
            return TBC::UNIT_NPC_FLAG_SPIRITGUIDE;
        case CLASSIC_UNIT_NPC_FLAG_INNKEEPER:
            return TBC::UNIT_NPC_FLAG_INNKEEPER;
        case CLASSIC_UNIT_NPC_FLAG_BANKER:
            return TBC::UNIT_NPC_FLAG_BANKER;
        case CLASSIC_UNIT_NPC_FLAG_PETITIONER:
            return TBC::UNIT_NPC_FLAG_PETITIONER;
        case CLASSIC_UNIT_NPC_FLAG_TABARDDESIGNER:
            return TBC::UNIT_NPC_FLAG_TABARDDESIGNER;
        case CLASSIC_UNIT_NPC_FLAG_BATTLEMASTER:
            return TBC::UNIT_NPC_FLAG_BATTLEMASTER;
        case CLASSIC_UNIT_NPC_FLAG_AUCTIONEER:
            return TBC::UNIT_NPC_FLAG_AUCTIONEER;
        case CLASSIC_UNIT_NPC_FLAG_STABLEMASTER:
            return TBC::UNIT_NPC_FLAG_STABLEMASTER;
        case CLASSIC_UNIT_NPC_FLAG_GUILD_BANKER:
            return TBC::UNIT_NPC_FLAG_GUILD_BANKER;
        case CLASSIC_UNIT_NPC_FLAG_SPELLCLICK:
            return TBC::UNIT_NPC_FLAG_SPELLCLICK;
    }
    return 0;
}

inline uint32 ConvertClassicNpcFlagToWotLK(uint32 flag)
{
    switch (flag)
    {
        case CLASSIC_UNIT_NPC_FLAG_GOSSIP:
            return WotLK::UNIT_NPC_FLAG_GOSSIP;
        case CLASSIC_UNIT_NPC_FLAG_QUESTGIVER:
            return WotLK::UNIT_NPC_FLAG_QUESTGIVER;
        case CLASSIC_UNIT_NPC_FLAG_TRAINER:
            return WotLK::UNIT_NPC_FLAG_TRAINER;
        case CLASSIC_UNIT_NPC_FLAG_TRAINER_CLASS:
            return WotLK::UNIT_NPC_FLAG_TRAINER_CLASS;
        case CLASSIC_UNIT_NPC_FLAG_TRAINER_PROFESSION:
            return WotLK::UNIT_NPC_FLAG_TRAINER_PROFESSION;
        case CLASSIC_UNIT_NPC_FLAG_VENDOR:
            return WotLK::UNIT_NPC_FLAG_VENDOR;
        case CLASSIC_UNIT_NPC_FLAG_VENDOR_AMMO:
            return WotLK::UNIT_NPC_FLAG_VENDOR_AMMO;
        case CLASSIC_UNIT_NPC_FLAG_VENDOR_FOOD:
            return WotLK::UNIT_NPC_FLAG_VENDOR_FOOD;
        case CLASSIC_UNIT_NPC_FLAG_VENDOR_POISON:
            return WotLK::UNIT_NPC_FLAG_VENDOR_POISON;
        case CLASSIC_UNIT_NPC_FLAG_VENDOR_REAGENT:
            return WotLK::UNIT_NPC_FLAG_VENDOR_REAGENT;
        case CLASSIC_UNIT_NPC_FLAG_REPAIR:
            return WotLK::UNIT_NPC_FLAG_REPAIR;
        case CLASSIC_UNIT_NPC_FLAG_FLIGHTMASTER:
            return WotLK::UNIT_NPC_FLAG_FLIGHTMASTER;
        case CLASSIC_UNIT_NPC_FLAG_SPIRITHEALER:
            return WotLK::UNIT_NPC_FLAG_SPIRITHEALER;
        case CLASSIC_UNIT_NPC_FLAG_SPIRITGUIDE:
            return WotLK::UNIT_NPC_FLAG_SPIRITGUIDE;
        case CLASSIC_UNIT_NPC_FLAG_INNKEEPER:
            return WotLK::UNIT_NPC_FLAG_INNKEEPER;
        case CLASSIC_UNIT_NPC_FLAG_BANKER:
            return WotLK::UNIT_NPC_FLAG_BANKER;
        case CLASSIC_UNIT_NPC_FLAG_PETITIONER:
            return WotLK::UNIT_NPC_FLAG_PETITIONER;
        case CLASSIC_UNIT_NPC_FLAG_TABARDDESIGNER:
            return WotLK::UNIT_NPC_FLAG_TABARDDESIGNER;
        case CLASSIC_UNIT_NPC_FLAG_BATTLEMASTER:
            return WotLK::UNIT_NPC_FLAG_BATTLEMASTER;
        case CLASSIC_UNIT_NPC_FLAG_AUCTIONEER:
            return WotLK::UNIT_NPC_FLAG_AUCTIONEER;
        case CLASSIC_UNIT_NPC_FLAG_STABLEMASTER:
            return WotLK::UNIT_NPC_FLAG_STABLEMASTER;
        case CLASSIC_UNIT_NPC_FLAG_GUILD_BANKER:
            return WotLK::UNIT_NPC_FLAG_GUILD_BANKER;
        case CLASSIC_UNIT_NPC_FLAG_SPELLCLICK:
            return WotLK::UNIT_NPC_FLAG_SPELLCLICK;
        case CLASSIC_UNIT_NPC_FLAG_PLAYER_VEHICLE:
            return WotLK::UNIT_NPC_FLAG_PLAYER_VEHICLE;
    }
    return 0;
}

inline uint32 ConvertClassicNpcFlagsToVanilla(uint32 flags)
{
    uint32 newFlags = 0;
    for (uint32 i = 0; i < CLASSIC_MAX_NPC_FLAGS; i++)
    {
        uint32 flag = (uint32)pow(2, i);
        if (flags & flag)
        {
            newFlags |= ConvertClassicNpcFlagToVanilla(flag);
        }
    }
    return newFlags;
}

inline uint32 ConvertClassicNpcFlagsToTBC(uint32 flags)
{
    uint32 newFlags = 0;
    for (uint32 i = 0; i < CLASSIC_MAX_NPC_FLAGS; i++)
    {
        uint32 flag = (uint32)pow(2, i);
        if (flags & flag)
        {
            newFlags |= ConvertClassicNpcFlagToTBC(flag);
        }
    }
    return newFlags;
}

inline uint32 ConvertClassicNpcFlagsToWotLK(uint32 flags)
{
    uint32 newFlags = 0;
    for (uint32 i = 0; i < CLASSIC_MAX_NPC_FLAGS; i++)
    {
        uint32 flag = (uint32)pow(2, i);
        if (flags & flag)
        {
            newFlags |= ConvertClassicNpcFlagToWotLK(flag);
        }
    }
    return newFlags;
}

enum ClassicSpellHitInfo
{
    CLASSIC_HITINFO_UNK0 = 0x00000001, // unused - debug flag, probably debugging visuals, no effect in non-ptr client
    CLASSIC_HITINFO_AFFECTS_VICTIM = 0x00000002,
    CLASSIC_HITINFO_OFFHAND = 0x00000004,
    CLASSIC_HITINFO_UNK3 = 0x00000008, // unused (3.3.5a)
    CLASSIC_HITINFO_MISS = 0x00000010,
    CLASSIC_HITINFO_FULL_ABSORB = 0x00000020,
    CLASSIC_HITINFO_PARTIAL_ABSORB = 0x00000040,
    CLASSIC_HITINFO_FULL_RESIST = 0x00000080,
    CLASSIC_HITINFO_PARTIAL_RESIST = 0x00000100,
    CLASSIC_HITINFO_CRITICALHIT = 0x00000200,
    CLASSIC_HITINFO_UNK10 = 0x00000400,
    CLASSIC_HITINFO_UNK11 = 0x00000800,
    CLASSIC_HITINFO_UNK12 = 0x00001000,
    CLASSIC_HITINFO_BLOCK = 0x00002000,
    CLASSIC_HITINFO_UNK14 = 0x00004000, // set only if meleespellid is present//  no world text when victim is hit for 0 dmg(HideWorldTextForNoDamage?)
    CLASSIC_HITINFO_UNK15 = 0x00008000, // player victim?// something related to blod sprut visual (BloodSpurtInBack?)
    CLASSIC_HITINFO_GLANCING = 0x00010000,
    CLASSIC_HITINFO_CRUSHING = 0x00020000,
    CLASSIC_HITINFO_NO_ANIMATION = 0x00040000, // set always for melee spells and when no hit animation should be displayed
    CLASSIC_HITINFO_UNK19 = 0x00080000,
    CLASSIC_HITINFO_UNK20 = 0x00100000,
    CLASSIC_HITINFO_UNK21 = 0x00200000, // unused (3.3.5a)
    CLASSIC_HITINFO_UNK22 = 0x00400000,
    CLASSIC_HITINFO_RAGE_GAIN = 0x00800000,
    CLASSIC_HITINFO_FAKE_DAMAGE = 0x01000000, // enables damage animation even if no damage done, set only if no damage
    CLASSIC_HITINFO_UNK25 = 0x02000000,
    CLASSIC_HITINFO_UNK26 = 0x04000000
};

inline uint32 ConvertClassicHitInfoFlagToVanilla(uint32 flag)
{
    switch (flag)
    {
        case CLASSIC_HITINFO_UNK0:
            return Vanilla::HITINFO_UNK0;
        case CLASSIC_HITINFO_AFFECTS_VICTIM:
            return Vanilla::HITINFO_AFFECTS_VICTIM;
        case CLASSIC_HITINFO_OFFHAND:
            return Vanilla::HITINFO_LEFTSWING;
        case CLASSIC_HITINFO_UNK3:
            return Vanilla::HITINFO_UNK3;
        case CLASSIC_HITINFO_MISS:
            return Vanilla::HITINFO_MISS;
        case CLASSIC_HITINFO_FULL_ABSORB:
            return Vanilla::HITINFO_ABSORB;
        case CLASSIC_HITINFO_PARTIAL_ABSORB:
            return Vanilla::HITINFO_ABSORB;
        case CLASSIC_HITINFO_FULL_RESIST:
            return Vanilla::HITINFO_RESIST;
        case CLASSIC_HITINFO_PARTIAL_RESIST:
            return Vanilla::HITINFO_RESIST;
        case CLASSIC_HITINFO_CRITICALHIT:
            return Vanilla::HITINFO_CRITICALHIT;
        case CLASSIC_HITINFO_GLANCING:
            return Vanilla::HITINFO_GLANCING;
        case CLASSIC_HITINFO_CRUSHING:
            return Vanilla::HITINFO_CRUSHING;
        case CLASSIC_HITINFO_NO_ANIMATION:
            return Vanilla::HITINFO_NOACTION;
    }

    return 0;
}

inline uint32 ConvertClassicHitInfoFlagToTBC(uint32 flag)
{
    switch (flag)
    {
        case CLASSIC_HITINFO_UNK0:
            return TBC::HITINFO_UNK0;
        case CLASSIC_HITINFO_AFFECTS_VICTIM:
            return TBC::HITINFO_AFFECTS_VICTIM;
        case CLASSIC_HITINFO_OFFHAND:
            return TBC::HITINFO_LEFTSWING;
        case CLASSIC_HITINFO_UNK3:
            return TBC::HITINFO_UNK3;
        case CLASSIC_HITINFO_MISS:
            return TBC::HITINFO_MISS;
        case CLASSIC_HITINFO_FULL_ABSORB:
            return TBC::HITINFO_ABSORB;
        case CLASSIC_HITINFO_PARTIAL_ABSORB:
            return TBC::HITINFO_ABSORB;
        case CLASSIC_HITINFO_FULL_RESIST:
            return TBC::HITINFO_RESIST;
        case CLASSIC_HITINFO_PARTIAL_RESIST:
            return TBC::HITINFO_RESIST;
        case CLASSIC_HITINFO_CRITICALHIT:
            return TBC::HITINFO_CRITICALHIT;
        case CLASSIC_HITINFO_GLANCING:
            return TBC::HITINFO_GLANCING;
        case CLASSIC_HITINFO_CRUSHING:
            return TBC::HITINFO_CRUSHING;
        case CLASSIC_HITINFO_NO_ANIMATION:
            return TBC::HITINFO_NOACTION;
    }

    return 0;
}

inline uint32 ConvertClassicHitInfoFlagToWotLK(uint32 flag)
{
    switch (flag)
    {
        case CLASSIC_HITINFO_UNK0:
            return WotLK::HITINFO_UNK0;
        case CLASSIC_HITINFO_AFFECTS_VICTIM:
            return WotLK::HITINFO_AFFECTS_VICTIM;
        case CLASSIC_HITINFO_OFFHAND:
            return WotLK::HITINFO_LEFTSWING;
        case CLASSIC_HITINFO_UNK3:
            return WotLK::HITINFO_UNK3;
        case CLASSIC_HITINFO_MISS:
            return WotLK::HITINFO_MISS;
        case CLASSIC_HITINFO_FULL_ABSORB:
            return WotLK::HITINFO_ABSORB;
        case CLASSIC_HITINFO_PARTIAL_ABSORB:
            return WotLK::HITINFO_ABSORB2;
        case CLASSIC_HITINFO_FULL_RESIST:
            return WotLK::HITINFO_RESIST;
        case CLASSIC_HITINFO_PARTIAL_RESIST:
            return WotLK::HITINFO_RESIST2;
        case CLASSIC_HITINFO_CRITICALHIT:
            return WotLK::HITINFO_CRITICALHIT;
        case CLASSIC_HITINFO_GLANCING:
            return WotLK::HITINFO_GLANCING;
        case CLASSIC_HITINFO_CRUSHING:
            return WotLK::HITINFO_CRUSHING;
        case CLASSIC_HITINFO_NO_ANIMATION:
            return WotLK::HITINFO_NOACTION;
    }

    return 0;
}

inline uint32 ConvertClassicHitInfoFlagsToVanilla(uint32 flags)
{
    uint32 newFlags = 0;
    for (uint32 i = 0; i < 32; i++)
    {
        uint32 flag = (uint32)pow(2, i);
        if (flags & flag)
        {
            newFlags |= ConvertClassicHitInfoFlagToVanilla(flag);
        }
    }
    return newFlags;
}

inline uint32 ConvertClassicHitInfoFlagsToTBC(uint32 flags)
{
    uint32 newFlags = 0;
    for (uint32 i = 0; i < 32; i++)
    {
        uint32 flag = (uint32)pow(2, i);
        if (flags & flag)
        {
            newFlags |= ConvertClassicHitInfoFlagToTBC(flag);
        }
    }
    return newFlags;
}

inline uint32 ConvertClassicHitInfoFlagsToWotLK(uint32 flags)
{
    uint32 newFlags = 0;
    for (uint32 i = 0; i < 32; i++)
    {
        uint32 flag = (uint32)pow(2, i);
        if (flags & flag)
        {
            newFlags |= ConvertClassicHitInfoFlagToWotLK(flag);
        }
    }
    return newFlags;
}

enum class ClassicMovementFlag : uint32
{
    None = 0x00000000,
    Forward = 0x00000001,
    Backward = 0x00000002,
    StrafeLeft = 0x00000004,
    StrafeRight = 0x00000008,
    Left = 0x00000010,
    Right = 0x00000020,
    PitchUp = 0x00000040,
    PitchDown = 0x00000080,
    Walking = 0x00000100,
    DisableGravity = 0x00000200,
    Root = 0x00000400,
    Falling = 0x00000800,
    FallingFar = 0x00001000,
    PendingStop = 0x00002000,
    PendingStrafeStop = 0x00004000,
    PendingForward = 0x00008000,
    PendingBackward = 0x00010000,
    PendingStrafeLeft = 0x00020000,
    PendingStrafeRight = 0x00040000,
    PendingRoot = 0x00080000,
    Swimming = 0x00100000,
    Ascending = 0x00200000,
    Descending = 0x00400000,
    CanFly = 0x00800000,
    Flying = 0x01000000,
    SplineElevation = 0x02000000,
    Waterwalking = 0x04000000,
    FallingSlow = 0x08000000,
    Hover = 0x10000000,
    DisableCollision = 0x20000000,
};

inline uint32 ConvertMovementFlagsToVanilla(uint32 flags)
{
    uint32 newFlags = 0;
    if (flags & (uint32)ClassicMovementFlag::Forward)
        newFlags |= Vanilla::MOVEFLAG_FORWARD;
    if (flags & (uint32)ClassicMovementFlag::Backward)
        newFlags |= Vanilla::MOVEFLAG_BACKWARD;
    if (flags & (uint32)ClassicMovementFlag::StrafeLeft)
        newFlags |= Vanilla::MOVEFLAG_STRAFE_LEFT;
    if (flags & (uint32)ClassicMovementFlag::StrafeRight)
        newFlags |= Vanilla::MOVEFLAG_STRAFE_RIGHT;
    if (flags & (uint32)ClassicMovementFlag::Left)
        newFlags |= Vanilla::MOVEFLAG_TURN_LEFT;
    if (flags & (uint32)ClassicMovementFlag::Right)
        newFlags |= Vanilla::MOVEFLAG_TURN_RIGHT;
    if (flags & (uint32)ClassicMovementFlag::PitchUp)
        newFlags |= Vanilla::MOVEFLAG_PITCH_UP;
    if (flags & (uint32)ClassicMovementFlag::PitchDown)
        newFlags |= Vanilla::MOVEFLAG_PITCH_DOWN;
    if (flags & (uint32)ClassicMovementFlag::Walking)
        newFlags |= Vanilla::MOVEFLAG_WALK_MODE;
    if (flags & (uint32)ClassicMovementFlag::Root)
        newFlags |= Vanilla::MOVEFLAG_ROOT;
    if (flags & (uint32)ClassicMovementFlag::Falling)
        newFlags |= Vanilla::MOVEFLAG_JUMPING;
    if (flags & (uint32)ClassicMovementFlag::FallingFar)
        newFlags |= Vanilla::MOVEFLAG_FALLINGFAR;
    if (flags & (uint32)ClassicMovementFlag::Swimming)
        newFlags |= Vanilla::MOVEFLAG_SWIMMING;
    if (flags & (uint32)ClassicMovementFlag::CanFly)
        newFlags |= Vanilla::MOVEFLAG_CAN_FLY;
    if (flags & (uint32)ClassicMovementFlag::Flying)
        newFlags |= Vanilla::MOVEFLAG_FLYING;
    if (flags & (uint32)ClassicMovementFlag::Waterwalking)
        newFlags |= Vanilla::MOVEFLAG_WATERWALKING;
    if (flags & (uint32)ClassicMovementFlag::FallingSlow)
        newFlags |= Vanilla::MOVEFLAG_SAFE_FALL;
    if (flags & (uint32)ClassicMovementFlag::Hover)
        newFlags |= Vanilla::MOVEFLAG_HOVER;
    return newFlags;
}

inline uint32 ConvertMovementFlagsToTBC(uint32 flags)
{
    uint32 newFlags = 0;
    if (flags & (uint32)ClassicMovementFlag::Forward)
        newFlags |= TBC::MOVEFLAG_FORWARD;
    if (flags & (uint32)ClassicMovementFlag::Backward)
        newFlags |= TBC::MOVEFLAG_BACKWARD;
    if (flags & (uint32)ClassicMovementFlag::StrafeLeft)
        newFlags |= TBC::MOVEFLAG_STRAFE_LEFT;
    if (flags & (uint32)ClassicMovementFlag::StrafeRight)
        newFlags |= TBC::MOVEFLAG_STRAFE_RIGHT;
    if (flags & (uint32)ClassicMovementFlag::Left)
        newFlags |= TBC::MOVEFLAG_TURN_LEFT;
    if (flags & (uint32)ClassicMovementFlag::Right)
        newFlags |= TBC::MOVEFLAG_TURN_RIGHT;
    if (flags & (uint32)ClassicMovementFlag::PitchUp)
        newFlags |= TBC::MOVEFLAG_PITCH_UP;
    if (flags & (uint32)ClassicMovementFlag::PitchDown)
        newFlags |= TBC::MOVEFLAG_PITCH_DOWN;
    if (flags & (uint32)ClassicMovementFlag::Walking)
        newFlags |= TBC::MOVEFLAG_WALK_MODE;
    if (flags & (uint32)ClassicMovementFlag::Root)
        newFlags |= TBC::MOVEFLAG_ROOT;
    if (flags & (uint32)ClassicMovementFlag::Falling)
        newFlags |= TBC::MOVEFLAG_JUMPING;
    if (flags & (uint32)ClassicMovementFlag::FallingFar)
        newFlags |= TBC::MOVEFLAG_FALLINGFAR;
    if (flags & (uint32)ClassicMovementFlag::Swimming)
        newFlags |= TBC::MOVEFLAG_SWIMMING;
    if (flags & (uint32)ClassicMovementFlag::Ascending)
        newFlags |= TBC::MOVEFLAG_ASCENDING;
    if (flags & (uint32)ClassicMovementFlag::CanFly)
        newFlags |= TBC::MOVEFLAG_CAN_FLY;
    if (flags & (uint32)ClassicMovementFlag::Flying)
        newFlags |= TBC::MOVEFLAG_FLYING;
    if (flags & (uint32)ClassicMovementFlag::Waterwalking)
        newFlags |= TBC::MOVEFLAG_WATERWALKING;
    if (flags & (uint32)ClassicMovementFlag::FallingSlow)
        newFlags |= TBC::MOVEFLAG_SAFE_FALL;
    if (flags & (uint32)ClassicMovementFlag::Hover)
        newFlags |= TBC::MOVEFLAG_HOVER;
    return newFlags;
}

inline uint32 ConvertMovementFlagsToWotLK(uint32 flags)
{
    uint32 newFlags = 0;
    if (flags & (uint32)ClassicMovementFlag::Forward)
        newFlags |= WotLK::MOVEFLAG_FORWARD;
    if (flags & (uint32)ClassicMovementFlag::Backward)
        newFlags |= WotLK::MOVEFLAG_BACKWARD;
    if (flags & (uint32)ClassicMovementFlag::StrafeLeft)
        newFlags |= WotLK::MOVEFLAG_STRAFE_LEFT;
    if (flags & (uint32)ClassicMovementFlag::StrafeRight)
        newFlags |= WotLK::MOVEFLAG_STRAFE_RIGHT;
    if (flags & (uint32)ClassicMovementFlag::Left)
        newFlags |= WotLK::MOVEFLAG_TURN_LEFT;
    if (flags & (uint32)ClassicMovementFlag::Right)
        newFlags |= WotLK::MOVEFLAG_TURN_RIGHT;
    if (flags & (uint32)ClassicMovementFlag::PitchUp)
        newFlags |= WotLK::MOVEFLAG_PITCH_UP;
    if (flags & (uint32)ClassicMovementFlag::PitchDown)
        newFlags |= WotLK::MOVEFLAG_PITCH_DOWN;
    if (flags & (uint32)ClassicMovementFlag::Walking)
        newFlags |= WotLK::MOVEFLAG_WALK_MODE;
    if (flags & (uint32)ClassicMovementFlag::Root)
        newFlags |= WotLK::MOVEFLAG_ROOT;
    if (flags & (uint32)ClassicMovementFlag::Falling)
        newFlags |= WotLK::MOVEFLAG_FALLING;
    if (flags & (uint32)ClassicMovementFlag::FallingFar)
        newFlags |= WotLK::MOVEFLAG_FALLINGFAR;
    if (flags & (uint32)ClassicMovementFlag::PendingStop)
        newFlags |= WotLK::MOVEFLAG_PENDINGSTOP;
    if (flags & (uint32)ClassicMovementFlag::PendingStrafeStop)
        newFlags |= WotLK::MOVEFLAG_PENDINGSTRAFESTOP;
    if (flags & (uint32)ClassicMovementFlag::PendingForward)
        newFlags |= WotLK::MOVEFLAG_PENDINGFORWARD;
    if (flags & (uint32)ClassicMovementFlag::PendingBackward)
        newFlags |= WotLK::MOVEFLAG_PENDINGBACKWARD;
    if (flags & (uint32)ClassicMovementFlag::PendingStrafeLeft)
        newFlags |= WotLK::MOVEFLAG_PENDINGSTRAFELEFT;
    if (flags & (uint32)ClassicMovementFlag::PendingStrafeRight)
        newFlags |= WotLK::MOVEFLAG_PENDINGSTRAFERIGHT;
    if (flags & (uint32)ClassicMovementFlag::PendingRoot)
        newFlags |= WotLK::MOVEFLAG_PENDINGROOT;
    if (flags & (uint32)ClassicMovementFlag::Swimming)
        newFlags |= WotLK::MOVEFLAG_SWIMMING;
    if (flags & (uint32)ClassicMovementFlag::Ascending)
        newFlags |= WotLK::MOVEFLAG_ASCENDING;
    if (flags & (uint32)ClassicMovementFlag::Descending)
        newFlags |= WotLK::MOVEFLAG_DESCENDING;
    if (flags & (uint32)ClassicMovementFlag::CanFly)
        newFlags |= WotLK::MOVEFLAG_CAN_FLY;
    if (flags & (uint32)ClassicMovementFlag::Flying)
        newFlags |= WotLK::MOVEFLAG_FLYING;
    if (flags & (uint32)ClassicMovementFlag::Waterwalking)
        newFlags |= WotLK::MOVEFLAG_WATERWALKING;
    if (flags & (uint32)ClassicMovementFlag::FallingSlow)
        newFlags |= WotLK::MOVEFLAG_SAFE_FALL;
    if (flags & (uint32)ClassicMovementFlag::Hover)
        newFlags |= WotLK::MOVEFLAG_HOVER;
    return newFlags;
}

enum class ClassicSplineFlag : uint32
{
    None                = 0x00000000,
    AnimTierSwim        = 0x00000001,
    AnimTierHover       = 0x00000002,
    AnimTierFly         = 0x00000003,
    AnimTierSubmerged   = 0x00000004,
    Unknown0            = 0x00000008,
    FallingSlow         = 0x00000010,
    Done                = 0x00000020,
    Falling             = 0x00000040,
    NoSpline            = 0x00000080,
    Unknown1            = 0x00000100,
    Flying              = 0x00000200,
    OrientationFixed    = 0x00000400,
    Catmullrom          = 0x00000800,
    Cyclic              = 0x00001000,
    EnterCycle          = 0x00002000,
    Frozen              = 0x00004000,
    TransportEnter      = 0x00008000,
    TransportExit       = 0x00010000,
    Unknown2            = 0x00020000,
    Unknown3            = 0x00040000,
    Backward            = 0x00080000,
    SmoothGroundPath    = 0x00100000,
    CanSwim             = 0x00200000,
    UncompressedPath    = 0x00400000,
    Unknown4            = 0x00800000,
    Unknown5            = 0x01000000,
    Animation           = 0x02000000,
    Parabolic           = 0x04000000,
    FadeObject          = 0x08000000,
    Steering            = 0x10000000,
    Unknown8            = 0x20000000,
    Unknown9            = 0x40000000,
    Unknown10           = 0x80000000,
};

enum class ClassicChatMessageType : uint8
{
    System = 0,
    Say = 1,
    Party = 2,
    Raid = 3,
    Guild = 4,
    Officer = 5,
    Yell = 6,
    Whisper = 7,
    Whisper2 = 8,
    WhisperInform = 9,
    Emote = 10,
    TextEmote = 11,
    MonsterSay = 12,
    MonsterParty = 13,
    MonsterYell = 14,
    MonsterWhisper = 15,
    MonsterEmote = 16,
    Channel = 17,
    ChannelJoin = 18,
    ChannelLeave = 19,
    ChannelList = 20,
    ChannelNotice = 21,
    ChannelNoticeUser = 22,
    Afk = 23,
    Dnd = 24,
    Ignored = 25,
    Skill = 26,
    Loot = 27,
    Money = 28,
    Opening = 29,
    Tradeskills = 30,
    PetInfo = 31,
    CombatMiscInfo = 32,
    CombatXpGain = 33,
    CombatHonorGain = 34,
    CombatFactionChange = 35,
    BgSystemNeutral = 36,
    BgSystemAlliance = 37,
    BgSystemHorde = 38,
    RaidLeader = 39,
    RaidWarning = 40,
    RaidBossEmote = 41,
    RaidBossWhisper = 42,
    Filtered = 43,
    Restricted = 44,
    //unused1 = 45,
    Achievement = 46,
    GuildAchievement = 47,
    //unused2 = 48,
    PartyLeader = 49,
    Targeticons = 50,
    BnWhisper = 51,
    BnWhisperInform = 52,
    BnConversation = 53,
    BnConversationNotice = 54,
    BnConversationList = 55,
    BnInlineToastAlert = 56,
    BnInlineToastBroadcast = 57,
    BnInlineToastBroadcastInform = 58,
    BnInlineToastConversation = 59,
    BnWhisperPlayerOffline = 60,
    CombatGuildXpGain = 61,
    Battleground = 62,
    BattlegroundLeader = 63,
    PetBattleCombatLog = 64,
    PetBattleInfo = 65,
    InstanceChat = 66,
    InstanceChatLeader = 67,
};

inline uint32 ConvertClassicChatTypeToVanilla(uint8 chatType)
{
    switch (ClassicChatMessageType(chatType))
    {
        case ClassicChatMessageType::Say:
            return Vanilla::CHAT_MSG_SAY;
        case ClassicChatMessageType::Party:
            return Vanilla::CHAT_MSG_PARTY;
        case ClassicChatMessageType::Raid:
            return Vanilla::CHAT_MSG_RAID;
        case ClassicChatMessageType::Guild:
            return Vanilla::CHAT_MSG_GUILD;
        case ClassicChatMessageType::Officer:
            return Vanilla::CHAT_MSG_OFFICER;
        case ClassicChatMessageType::Yell:
            return Vanilla::CHAT_MSG_YELL;
        case ClassicChatMessageType::Whisper:
            return Vanilla::CHAT_MSG_WHISPER;
        case ClassicChatMessageType::Whisper2:
            return Vanilla::CHAT_MSG_WHISPER;
        case ClassicChatMessageType::WhisperInform:
            return Vanilla::CHAT_MSG_WHISPER_INFORM;
        case ClassicChatMessageType::Emote:
            return Vanilla::CHAT_MSG_EMOTE;
        case ClassicChatMessageType::TextEmote:
            return Vanilla::CHAT_MSG_TEXT_EMOTE;
        case ClassicChatMessageType::Channel:
            return Vanilla::CHAT_MSG_CHANNEL;
        case ClassicChatMessageType::BgSystemNeutral:
            return Vanilla::CHAT_MSG_BG_SYSTEM_NEUTRAL;
        case ClassicChatMessageType::BgSystemAlliance:
            return Vanilla::CHAT_MSG_BG_SYSTEM_ALLIANCE;
        case ClassicChatMessageType::BgSystemHorde:
            return Vanilla::CHAT_MSG_BG_SYSTEM_HORDE;
        case ClassicChatMessageType::RaidLeader:
            return Vanilla::CHAT_MSG_RAID_LEADER;
        case ClassicChatMessageType::RaidWarning:
            return Vanilla::CHAT_MSG_RAID_WARNING;
        case ClassicChatMessageType::PartyLeader:
            return Vanilla::CHAT_MSG_PARTY;
        case ClassicChatMessageType::BnWhisper:
            return Vanilla::CHAT_MSG_WHISPER;
        case ClassicChatMessageType::BnWhisperInform:
            return Vanilla::CHAT_MSG_WHISPER_INFORM;
        case ClassicChatMessageType::Battleground:
            return Vanilla::CHAT_MSG_BATTLEGROUND;
        case ClassicChatMessageType::BattlegroundLeader:
            return Vanilla::CHAT_MSG_BATTLEGROUND_LEADER;
        case ClassicChatMessageType::InstanceChat:
            return Vanilla::CHAT_MSG_PARTY;
        case ClassicChatMessageType::InstanceChatLeader:
            return Vanilla::CHAT_MSG_PARTY;
    }
    return Vanilla::CHAT_MSG_SAY;
}

inline uint32 ConvertClassicChatTypeToTBC(uint8 chatType)
{
    switch (ClassicChatMessageType(chatType))
    {
        case ClassicChatMessageType::Say:
            return TBC::CHAT_MSG_SAY;
        case ClassicChatMessageType::Party:
            return TBC::CHAT_MSG_PARTY;
        case ClassicChatMessageType::Raid:
            return TBC::CHAT_MSG_RAID;
        case ClassicChatMessageType::Guild:
            return TBC::CHAT_MSG_GUILD;
        case ClassicChatMessageType::Officer:
            return TBC::CHAT_MSG_OFFICER;
        case ClassicChatMessageType::Yell:
            return TBC::CHAT_MSG_YELL;
        case ClassicChatMessageType::Whisper:
            return TBC::CHAT_MSG_WHISPER;
        case ClassicChatMessageType::Whisper2:
            return TBC::CHAT_MSG_WHISPER;
        case ClassicChatMessageType::WhisperInform:
            return TBC::CHAT_MSG_WHISPER_INFORM;
        case ClassicChatMessageType::Emote:
            return TBC::CHAT_MSG_EMOTE;
        case ClassicChatMessageType::TextEmote:
            return TBC::CHAT_MSG_TEXT_EMOTE;
        case ClassicChatMessageType::Channel:
            return TBC::CHAT_MSG_CHANNEL;
        case ClassicChatMessageType::BgSystemNeutral:
            return TBC::CHAT_MSG_BG_SYSTEM_NEUTRAL;
        case ClassicChatMessageType::BgSystemAlliance:
            return TBC::CHAT_MSG_BG_SYSTEM_ALLIANCE;
        case ClassicChatMessageType::BgSystemHorde:
            return TBC::CHAT_MSG_BG_SYSTEM_HORDE;
        case ClassicChatMessageType::RaidLeader:
            return TBC::CHAT_MSG_RAID_LEADER;
        case ClassicChatMessageType::RaidWarning:
            return TBC::CHAT_MSG_RAID_WARNING;
        case ClassicChatMessageType::PartyLeader:
            return TBC::CHAT_MSG_PARTY;
        case ClassicChatMessageType::BnWhisper:
            return TBC::CHAT_MSG_WHISPER;
        case ClassicChatMessageType::BnWhisperInform:
            return TBC::CHAT_MSG_WHISPER_INFORM;
        case ClassicChatMessageType::Battleground:
            return TBC::CHAT_MSG_BATTLEGROUND;
        case ClassicChatMessageType::BattlegroundLeader:
            return TBC::CHAT_MSG_BATTLEGROUND_LEADER;
        case ClassicChatMessageType::InstanceChat:
            return TBC::CHAT_MSG_PARTY;
        case ClassicChatMessageType::InstanceChatLeader:
            return TBC::CHAT_MSG_PARTY;
    }
    return TBC::CHAT_MSG_SAY;
}

inline uint32 ConvertClassicChatTypeToWotLK(uint8 chatType)
{
    switch (ClassicChatMessageType(chatType))
    {
        case ClassicChatMessageType::Say:
            return WotLK::CHAT_MSG_SAY;
        case ClassicChatMessageType::Party:
            return WotLK::CHAT_MSG_PARTY;
        case ClassicChatMessageType::Raid:
            return WotLK::CHAT_MSG_RAID;
        case ClassicChatMessageType::Guild:
            return WotLK::CHAT_MSG_GUILD;
        case ClassicChatMessageType::Officer:
            return WotLK::CHAT_MSG_OFFICER;
        case ClassicChatMessageType::Yell:
            return WotLK::CHAT_MSG_YELL;
        case ClassicChatMessageType::Whisper:
            return WotLK::CHAT_MSG_WHISPER;
        case ClassicChatMessageType::Whisper2:
            return WotLK::CHAT_MSG_WHISPER;
        case ClassicChatMessageType::WhisperInform:
            return WotLK::CHAT_MSG_WHISPER_INFORM;
        case ClassicChatMessageType::Emote:
            return WotLK::CHAT_MSG_EMOTE;
        case ClassicChatMessageType::TextEmote:
            return WotLK::CHAT_MSG_TEXT_EMOTE;
        case ClassicChatMessageType::Channel:
            return WotLK::CHAT_MSG_CHANNEL;
        case ClassicChatMessageType::BgSystemNeutral:
            return WotLK::CHAT_MSG_BG_SYSTEM_NEUTRAL;
        case ClassicChatMessageType::BgSystemAlliance:
            return WotLK::CHAT_MSG_BG_SYSTEM_ALLIANCE;
        case ClassicChatMessageType::BgSystemHorde:
            return WotLK::CHAT_MSG_BG_SYSTEM_HORDE;
        case ClassicChatMessageType::RaidLeader:
            return WotLK::CHAT_MSG_RAID_LEADER;
        case ClassicChatMessageType::RaidWarning:
            return WotLK::CHAT_MSG_RAID_WARNING;
        case ClassicChatMessageType::PartyLeader:
            return WotLK::CHAT_MSG_PARTY;
        case ClassicChatMessageType::BnWhisper:
            return WotLK::CHAT_MSG_WHISPER;
        case ClassicChatMessageType::BnWhisperInform:
            return WotLK::CHAT_MSG_WHISPER_INFORM;
        case ClassicChatMessageType::Battleground:
            return WotLK::CHAT_MSG_BATTLEGROUND;
        case ClassicChatMessageType::BattlegroundLeader:
            return WotLK::CHAT_MSG_BATTLEGROUND_LEADER;
        case ClassicChatMessageType::InstanceChat:
            return WotLK::CHAT_MSG_PARTY;
        case ClassicChatMessageType::InstanceChatLeader:
            return WotLK::CHAT_MSG_PARTY;
    }
    return WotLK::CHAT_MSG_SAY;
}

#endif