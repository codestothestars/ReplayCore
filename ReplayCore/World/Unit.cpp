#include "Unit.h"
#include "WorldServer.h"
#include "ReplayMgr.h"
#include "GameDataMgr.h"
#include "../Defines/ClientVersions.h"

float baseMoveSpeed[MAX_MOVE_TYPE_WOTLK] =
{
    2.5f,                                                   // MOVE_WALK
    7.0f,                                                   // MOVE_RUN
    4.5f,                                                   // MOVE_RUN_BACK
    4.722222f,                                              // MOVE_SWIM
    2.5f,                                                   // MOVE_SWIM_BACK
    3.141594f,                                              // MOVE_TURN_RATE
    7.0f,                                                   // MOVE_FLIGHT
    4.5f,                                                   // MOVE_FLIGHT_BACK
    3.14f                                                   // MOVE_PITCH_RATE
};

Unit::Unit(UnitData const& unitData) : WorldObject(unitData.guid)
{
    m_objectType |= TYPEMASK_UNIT;
    m_objectTypeId = TYPEID_UNIT;
    m_updateFlags = (UPDATEFLAG_ALL | UPDATEFLAG_LIVING | UPDATEFLAG_HAS_POSITION);
    InitializeMoveSpeeds();

    m_valuesCount = sWorld.GetUpdateField("UNIT_END");
    assert(m_valuesCount);
    m_uint32Values = new uint32[m_valuesCount];
    memset(m_uint32Values, 0, m_valuesCount * sizeof(uint32));
    unitData.InitializeUnit(this);
    m_uint32Values_mirror = new uint32[m_valuesCount];
    memcpy(m_uint32Values_mirror, m_uint32Values, sizeof(uint32) * m_valuesCount);
}

void Unit::InitializeMoveSpeeds()
{
    for (int i = 0; i < MAX_MOVE_TYPE_WOTLK; i++)
        m_speedRate[i] = baseMoveSpeed[i];
}

void Unit::SetVirtualItem(uint8 slot, uint32 item_id)
{
    if (sWorld.GetClientBuild() < CLIENT_BUILD_2_0_1)
    {
        uint16 const UNIT_VIRTUAL_ITEM_SLOT_DISPLAY = sWorld.GetUpdateField("UNIT_VIRTUAL_ITEM_SLOT_DISPLAY");
        uint16 const UNIT_VIRTUAL_ITEM_INFO = sWorld.GetUpdateField("UNIT_VIRTUAL_ITEM_INFO");
        assert(UNIT_VIRTUAL_ITEM_SLOT_DISPLAY);
        assert(UNIT_VIRTUAL_ITEM_INFO);

        if (item_id == 0)
        {
            SetUInt32Value(UNIT_VIRTUAL_ITEM_SLOT_DISPLAY + slot, 0);
            SetUInt32Value(UNIT_VIRTUAL_ITEM_INFO + (slot * 2) + 0, 0);
            SetUInt32Value(UNIT_VIRTUAL_ITEM_INFO + (slot * 2) + 1, 0);
            return;
        }

        ItemPrototype const* proto = sGameDataMgr.GetItemPrototype(item_id);
        if (!proto)
        {
            printf("Not listed in 'item_template' item (ID:%u) used as virtual item for %s", item_id, GetGuidStr().c_str());
            return;
        }

        SetUInt32Value(UNIT_VIRTUAL_ITEM_SLOT_DISPLAY + slot, proto->DisplayInfoID);
        SetByteValue(UNIT_VIRTUAL_ITEM_INFO + (slot * 2) + 0, Vanilla::VIRTUAL_ITEM_INFO_0_OFFSET_CLASS, proto->Class);
        SetByteValue(UNIT_VIRTUAL_ITEM_INFO + (slot * 2) + 0, Vanilla::VIRTUAL_ITEM_INFO_0_OFFSET_SUBCLASS, proto->SubClass);
        SetByteValue(UNIT_VIRTUAL_ITEM_INFO + (slot * 2) + 0, Vanilla::VIRTUAL_ITEM_INFO_0_OFFSET_MATERIAL, proto->Material);
        SetByteValue(UNIT_VIRTUAL_ITEM_INFO + (slot * 2) + 0, Vanilla::VIRTUAL_ITEM_INFO_0_OFFSET_INVENTORYTYPE, proto->InventoryType);

        SetByteValue(UNIT_VIRTUAL_ITEM_INFO + (slot * 2) + 1, Vanilla::VIRTUAL_ITEM_INFO_1_OFFSET_SHEATH, proto->Sheath);
    }
    else if (sWorld.GetClientBuild() < CLIENT_BUILD_3_0_2)
    {
        uint16 const UNIT_VIRTUAL_ITEM_SLOT_DISPLAY = sWorld.GetUpdateField("UNIT_VIRTUAL_ITEM_SLOT_DISPLAY");
        uint16 const UNIT_VIRTUAL_ITEM_INFO = sWorld.GetUpdateField("UNIT_VIRTUAL_ITEM_INFO");
        assert(UNIT_VIRTUAL_ITEM_SLOT_DISPLAY);
        assert(UNIT_VIRTUAL_ITEM_INFO);

        if (item_id == 0)
        {
            SetUInt32Value(UNIT_VIRTUAL_ITEM_SLOT_DISPLAY + slot, 0);
            SetUInt32Value(UNIT_VIRTUAL_ITEM_INFO + (slot * 2) + 0, 0);
            SetUInt32Value(UNIT_VIRTUAL_ITEM_INFO + (slot * 2) + 1, 0);
            return;
        }

        ItemPrototype const* proto = sGameDataMgr.GetItemPrototype(item_id);
        if (!proto)
        {
            printf("Not listed in 'item_template' item (ID:%u) used as virtual item for %s", item_id, GetGuidStr().c_str());
            return;
        }

        SetUInt32Value(UNIT_VIRTUAL_ITEM_SLOT_DISPLAY + slot, proto->DisplayInfoID);
        SetByteValue(UNIT_VIRTUAL_ITEM_INFO + (slot * 2) + 0, TBC::VIRTUAL_ITEM_INFO_0_OFFSET_CLASS, proto->Class);
        SetByteValue(UNIT_VIRTUAL_ITEM_INFO + (slot * 2) + 0, TBC::VIRTUAL_ITEM_INFO_0_OFFSET_SUBCLASS, proto->SubClass);
        SetByteValue(UNIT_VIRTUAL_ITEM_INFO + (slot * 2) + 0, TBC::VIRTUAL_ITEM_INFO_0_OFFSET_UNK0, proto->Unk0);
        SetByteValue(UNIT_VIRTUAL_ITEM_INFO + (slot * 2) + 0, TBC::VIRTUAL_ITEM_INFO_0_OFFSET_MATERIAL, proto->Material);
        SetByteValue(UNIT_VIRTUAL_ITEM_INFO + (slot * 2) + 1, TBC::VIRTUAL_ITEM_INFO_1_OFFSET_INVENTORYTYPE, proto->InventoryType);

        SetByteValue(UNIT_VIRTUAL_ITEM_INFO + (slot * 2) + 1, TBC::VIRTUAL_ITEM_INFO_1_OFFSET_SHEATH, proto->Sheath);
    }
    else if (uint16 uf = sWorld.GetUpdateField("UNIT_VIRTUAL_ITEM_SLOT_ID"))
        SetUInt32Value(uf + slot, item_id);
}

uint32 Unit::GetAttackTime(WeaponAttackType att) const
{
    if (uint16 uf = sWorld.GetUpdateField("UNIT_FIELD_BASEATTACKTIME"))
        return GetUInt32Value(uf + att);
}

void Unit::SetAttackTime(WeaponAttackType att, uint32 val)
{
    if (uint16 uf = sWorld.GetUpdateField("UNIT_FIELD_BASEATTACKTIME"))
        return SetUInt32Value(uf + att, val);
}
