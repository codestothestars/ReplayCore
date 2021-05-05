#include "MoveSpline.h"
#include "MovementDefines.h"
#include "Unit.h"
#include "ReplayMgr.h"
#include "WorldServer.h"
#include "../Defines/ClientVersions.h"

uint32 MoveSpline::m_maxId = 0;

void MoveSpline::Initialize(Vector3 const& startPosition, uint32 moveTime, uint8 type, uint32 flags, float orientation, std::vector<Vector3> const& destinationPoints, bool isCyclic, bool isCatmullrom)
{
    m_id = m_maxId++;
    m_startTimeMs = sReplayMgr.GetCurrentSniffTimeMs();
    m_startPosition = startPosition;
    m_moveTimeMs = moveTime;
    m_type = type;
    m_flags = flags;
    m_finalOrientation = orientation;
    m_destinationPoints = destinationPoints;
    if (m_destinationPoints.empty() && m_type != SPLINE_TYPE_STOP)
        m_destinationPoints.push_back(startPosition);
    m_cyclic = isCyclic;
    m_catmullrom = isCatmullrom;
    m_initialized = true;
}

void MoveSpline::WriteMove(ByteBuffer &data) const
{
    data << float(m_startPosition.x);
    data << float(m_startPosition.y);
    data << float(m_startPosition.z);
    data << uint32(m_id);
    data << uint8(m_type);
    if (m_type == SPLINE_TYPE_STOP)
        return;
    else if (m_type == SPLINE_TYPE_FACING_ANGLE)
        data << float(m_finalOrientation);
    data << uint32(m_flags);
    data << uint32(m_moveTimeMs);
    
    uint32 pointsCount = m_destinationPoints.size();
    data << uint32(pointsCount);
    if (pointsCount > 0)
    {
        if (m_catmullrom || pointsCount == 1)
        {
            for (auto const& itr : m_destinationPoints)
            {
                data << float(itr.x);
                data << float(itr.y);
                data << float(itr.z);
            }
        }
        else
        {
            // final destination
            uint32 finalPointIndex = pointsCount - 1;
            data << float(m_destinationPoints[finalPointIndex].x);
            data << float(m_destinationPoints[finalPointIndex].y);
            data << float(m_destinationPoints[finalPointIndex].z);

            // other points
            for (uint32 i = 0; i < (pointsCount - 1); i++)
            {
                data << float(m_destinationPoints[i].x);
                data << float(m_destinationPoints[i].y);
                data << float(m_destinationPoints[i].z);
            }
        }
    }
}

void MoveSpline::WriteCreate(ByteBuffer &data) const
{
    uint32 splineFlags = m_flags;
    if (m_type == SPLINE_TYPE_FACING_ANGLE)
    {
        if (sWorld.GetClientBuild() < CLIENT_BUILD_2_0_1)
            splineFlags |= Vanilla::Final_Angle;
        else if (sWorld.GetClientBuild() < CLIENT_BUILD_3_0_2)
            splineFlags |= TBC::Final_Angle;
        else
            splineFlags |= WotLK::Final_Angle;
    }
    data << uint32(splineFlags);
    if (m_type == SPLINE_TYPE_FACING_ANGLE)
        data << float(m_finalOrientation);
    data << uint32(1 + sReplayMgr.GetCurrentSniffTimeMs() - m_startTimeMs);
    data << uint32(m_moveTimeMs);
    data << uint32(m_id);

    if (sWorld.GetClientBuild() >= CLIENT_BUILD_3_1_0)
    {
        data << float(1.0f); // Spline Duration Multiplier
        data << float(1.0f); // Spline Duration Multiplier Next
        data << float(1.0f); // Spline Vertical Acceleration
        data << uint32(m_startTimeMs); // Spline Start Time
    }

    assert(!m_destinationPoints.empty());

    uint32 pointsCount = std::max<uint32>(4, m_destinationPoints.size());
    data << uint32(pointsCount);
    for (auto const& itr : m_destinationPoints)
    {
        data << float(itr.x);
        data << float(itr.y);
        data << float(itr.z);
    }
    if (m_destinationPoints.size() < 4)
    {
        for (uint32 i = 0; i < (4 - m_destinationPoints.size()); i++)
        {
            data << float(m_destinationPoints[0].x);
            data << float(m_destinationPoints[0].y);
            data << float(m_destinationPoints[0].z);
        }
    }

    if (sWorld.GetClientBuild() >= CLIENT_BUILD_3_0_8)
        data << uint8(m_catmullrom ? 1 : 0); // Spline Mode

    uint32 finalPointIndex = m_destinationPoints.size() - 1;
    data << float(m_destinationPoints[finalPointIndex].x);
    data << float(m_destinationPoints[finalPointIndex].y);
    data << float(m_destinationPoints[finalPointIndex].z);
}

void MoveSpline::Update(Unit* pUnit)
{
    if (!m_initialized || m_cyclic || !m_moveTimeMs)
        return;

    if (sReplayMgr.GetCurrentSniffTimeMs() < m_startTimeMs)
    {
        if (sWorld.GetClientBuild() < CLIENT_BUILD_2_0_1)
            pUnit->RemoveUnitMovementFlag(Vanilla::MOVEFLAG_MASK_MOVING_OR_TURN | Vanilla::MOVEFLAG_SPLINE_ENABLED);
        else if (sWorld.GetClientBuild() < CLIENT_BUILD_3_0_2)
            pUnit->RemoveUnitMovementFlag(TBC::MOVEFLAG_MASK_MOVING_OR_TURN | TBC::MOVEFLAG_SPLINE_ENABLED);
        else
            pUnit->RemoveUnitMovementFlag(WotLK::MOVEFLAG_MASK_MOVING_OR_TURN | WotLK::MOVEFLAG_SPLINE_ENABLED);

        Reset();
        return;
    }

    uint64 elapsedTime = sReplayMgr.GetCurrentSniffTimeMs() - m_startTimeMs;
    if (!elapsedTime)
        return;

    if (elapsedTime >= m_moveTimeMs)
    {
        if (m_finalOrientation != 100)
            pUnit->Relocate(m_destinationPoints[0].x, m_destinationPoints[0].y, m_destinationPoints[0].z, m_finalOrientation);
        else
            pUnit->Relocate(m_destinationPoints[0].x, m_destinationPoints[0].y, m_destinationPoints[0].z);

        if (sWorld.GetClientBuild() < CLIENT_BUILD_2_0_1)
            pUnit->RemoveUnitMovementFlag(Vanilla::MOVEFLAG_MASK_MOVING_OR_TURN | Vanilla::MOVEFLAG_SPLINE_ENABLED);
        else if (sWorld.GetClientBuild() < CLIENT_BUILD_3_0_2)
            pUnit->RemoveUnitMovementFlag(TBC::MOVEFLAG_MASK_MOVING_OR_TURN | TBC::MOVEFLAG_SPLINE_ENABLED);
        else
            pUnit->RemoveUnitMovementFlag(WotLK::MOVEFLAG_MASK_MOVING_OR_TURN | WotLK::MOVEFLAG_SPLINE_ENABLED);

        Reset();
        return;
    }

    if (m_destinationPoints.size() > 1)
    {
        float percentDone = float(elapsedTime) / float(m_moveTimeMs);
        uint32 reachedPoint = m_destinationPoints.size() * percentDone;
        if (reachedPoint > 1)
            pUnit->Relocate(m_destinationPoints[reachedPoint].x, m_destinationPoints[reachedPoint].y, m_destinationPoints[reachedPoint].z);
    }
}