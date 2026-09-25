SELECT * FROM FlyTipIncidents
SELECT * FROM FactIntelligenceReport
SELECT * FROM FACTinforcementCases
SELECT * FROM DimCouncil
SELECT * FROM DimLocation
SELECT * FROM DimWasteType


/* --------------------------------------------------------------------------
Q1 — Areas with highest incident volumes
 --------------------------------------------------------------------------*/

USE Flytipping;
GO

WITH LocationMap AS
(
    SELECT
        LocationID,
        CouncilID,
        Area,
        ROW_NUMBER() OVER
        (
            PARTITION BY LocationID
            ORDER BY LocationKey
        ) AS rn
    FROM dbo.DimLocation
)
SELECT
    lm.CouncilID,
    c.CouncilName,
    c.Region,
    lm.Area,
    COUNT(*) AS IncidentCount
FROM dbo.FlyTipIncidents AS f
INNER JOIN LocationMap AS lm
    ON f.LocationID = lm.LocationID
   AND lm.rn = 1
INNER JOIN dbo.DimCouncil AS c
    ON lm.CouncilID = c.CouncilID
GROUP BY
    lm.CouncilID,
    c.CouncilName,
    c.Region,
    lm.Area
ORDER BY
    IncidentCount DESC;

/* --------------------------------------------------------------------------
Q2 — Top 10 Areas with highest incident volumes
 --------------------------------------------------------------------------*/
 WITH LocationMap AS
(
    SELECT
        LocationID,
        CouncilID,
        Area,
        ROW_NUMBER() OVER
        (
            PARTITION BY LocationID
            ORDER BY LocationKey
        ) AS rn
    FROM dbo.DimLocation
)
SELECT TOP (10)
    lm.Area,
    COUNT(*) AS IncidentCount
FROM dbo.FlyTipIncidents AS f
INNER JOIN LocationMap AS lm
    ON f.LocationID = lm.LocationID
   AND lm.rn = 1
GROUP BY lm.Area
ORDER BY IncidentCount DESC;

/* --------------------------------------------------------------------------
Q3 — Repeat hotspot (A repeat hotspot is a location with multiple incidents. This query ranks locations by incident volume.)
 --------------------------------------------------------------------------*/
 WITH LocationMap AS
(
    SELECT
        LocationID,
        CouncilID,
        Area,
        LocationType,
        RiskZone,
        ROW_NUMBER() OVER
        (
            PARTITION BY LocationID
            ORDER BY LocationKey
        ) AS rn
    FROM dbo.DimLocation
)
SELECT
    f.LocationID,
    lm.Area,
    lm.LocationType,
    lm.RiskZone,
    COUNT(*) AS IncidentCount,
    MIN(f.ReportDate) AS FirstIncidentDate,
    MAX(f.ReportDate) AS LatestIncidentDate,
    DATEDIFF
    (
        DAY,
        MIN(f.ReportDate),
        MAX(f.ReportDate)
    ) AS ActivePeriodDays
FROM dbo.FlyTipIncidents AS f
INNER JOIN LocationMap AS lm
    ON f.LocationID = lm.LocationID
   AND lm.rn = 1
GROUP BY
    f.LocationID,
    lm.Area,
    lm.LocationType,
    lm.RiskZone
HAVING COUNT(*) >= 2
ORDER BY
    IncidentCount DESC,
    LatestIncidentDate DESC;
/* --------------------------------------------------------------------------
Q4 - Identify particularly serious repeat hotspots 
--------------------------------------------------------------------------*/
WITH LocationMap AS
(
    SELECT
        LocationID,
        Area,
        LocationType,
        RiskZone,
        ROW_NUMBER() OVER
        (
            PARTITION BY LocationID
            ORDER BY LocationKey
        ) AS rn
    FROM dbo.DimLocation
)
SELECT
    f.LocationID,
    lm.Area,
    lm.LocationType,
    lm.RiskZone,
    COUNT(*) AS IncidentCount,
    SUM
    (
        CASE
            WHEN f.Severity = 'Critical' THEN 1
            ELSE 0
        END
    ) AS CriticalIncidents,
    SUM
    (
        CASE
            WHEN f.Severity = 'High' THEN 1
            ELSE 0
        END
    ) AS HighIncidents
FROM dbo.FlyTipIncidents AS f
INNER JOIN LocationMap AS lm
    ON f.LocationID = lm.LocationID
   AND lm.rn = 1
GROUP BY
    f.LocationID,
    lm.Area,
    lm.LocationType,
    lm.RiskZone
HAVING COUNT(*) >= 2
ORDER BY
    CriticalIncidents DESC,
    HighIncidents DESC,
    IncidentCount DESC;

    /*--------------------------------------------------------------------------------------
    Q5 — Locations increasing year over year
    ----------------------------------------------------------------------------------------*/
    WITH LocationMap AS
(
    SELECT
        LocationID,
        Area,
        LocationType,
        ROW_NUMBER() OVER
        (
            PARTITION BY LocationID
            ORDER BY LocationKey
        ) AS rn
    FROM dbo.DimLocation
),
PeriodCounts AS
(
    SELECT
        LocationID,
        SUM
        (
            CASE
                WHEN ReportDate BETWEEN '20250412' AND '20250930'
                    THEN 1
                ELSE 0
            END
        ) AS FirstPeriodIncidents_2025,
        SUM
        (
            CASE
                WHEN ReportDate BETWEEN '20251001' AND '20260330'
                    THEN 1
                ELSE 0
            END
        ) AS SecondPeriodIncidents_2026
    FROM dbo.FlyTipIncidents
    GROUP BY LocationID
)
SELECT
    p.LocationID,
    lm.Area,
    lm.LocationType,
    p.FirstPeriodIncidents_2025,
    p.SecondPeriodIncidents_2026,
    p.SecondPeriodIncidents_2026 - p.FirstPeriodIncidents_2025 AS IncidentChange,
    CASE
        WHEN p.FirstPeriodIncidents_2025 = 0 THEN NULL
        ELSE CAST
        (
            (
                (p.SecondPeriodIncidents_2026 - p.FirstPeriodIncidents_2025) * 100.0
            )
            / p.FirstPeriodIncidents_2025
            AS DECIMAL(10,2)
        )
    END AS GrowthPercentage
FROM PeriodCounts AS p
INNER JOIN LocationMap AS lm
    ON p.LocationID = lm.LocationID
   AND lm.rn = 1
WHERE p.SecondPeriodIncidents_2026 > p.FirstPeriodIncidents_2025
ORDER BY GrowthPercentage DESC;


    /*--------------------------------------------------------------------------------------
    Q6 — Waste types increasing
    ----------------------------------------------------------------------------------------*/
    WITH WastePeriodCounts AS
(
    SELECT
        WasteTypeID,
        SUM
        (
            CASE
                WHEN ReportDate BETWEEN '20250412' AND '20250930'
                    THEN 1
                ELSE 0
            END
        ) AS FirstPeriodIncidents,
        SUM
        (
            CASE
                WHEN ReportDate BETWEEN '20251001' AND '20260330'
                    THEN 1
                ELSE 0
            END
        ) AS SecondPeriodIncidents
    FROM dbo.FlyTipIncidents
    GROUP BY WasteTypeID
)
SELECT
    p.WasteTypeID,
    w.WasteType,
    w.RiskCategory,
    p.FirstPeriodIncidents,
    p.SecondPeriodIncidents,
    p.SecondPeriodIncidents - p.FirstPeriodIncidents AS IncidentChange,
    CASE
        WHEN p.FirstPeriodIncidents = 0 THEN NULL
        ELSE CAST
        (
            (
                (p.SecondPeriodIncidents - p.FirstPeriodIncidents) * 100.0
            )
            / p.FirstPeriodIncidents
            AS DECIMAL(10,2)
        )
    END AS GrowthPercentage
FROM WastePeriodCounts AS p
INNER JOIN dbo.DimWasteType AS w
    ON p.WasteTypeID = w.WasteTypeID
WHERE p.SecondPeriodIncidents > p.FirstPeriodIncidents
ORDER BY GrowthPercentage DESC;

    /*--------------------------------------------------------------------------------------
    Q7 — Days, months, and time periods
    ----------------------------------------------------------------------------------------*/
    -- Incidents by day of week
    SELECT
    DATEPART
    (
        WEEKDAY,
        DATEADD
        (
            DAY,
            DATEDIFF(DAY, '19000101', ReportDate),
            '19000101'
        )
    ) AS WeekdayNumber,

    DATENAME
    (
        WEEKDAY,
        ReportDate
    ) AS DayOfWeek,

    COUNT(*) AS IncidentCount
FROM dbo.FlyTipIncidents
GROUP BY
    DATEPART
    (
        WEEKDAY,
        DATEADD
        (
            DAY,
            DATEDIFF(DAY, '19000101', ReportDate),
            '19000101'
        )
    ),
    DATENAME(WEEKDAY, ReportDate)
ORDER BY
    WeekdayNumber;

    -- Incident by Month
    SELECT
    YEAR(ReportDate) AS IncidentYear,
    MONTH(ReportDate) AS MonthNumber,
    DATENAME(MONTH, ReportDate) AS MonthName,
    COUNT(*) AS IncidentCount
FROM dbo.FlyTipIncidents
GROUP BY
    YEAR(ReportDate),
    MONTH(ReportDate),
    DATENAME(MONTH, ReportDate)
ORDER BY
    IncidentYear,
    MonthNumber;

    -- Incidents by month across all years
    SELECT
    MONTH(ReportDate) AS MonthNumber,
    DATENAME(MONTH, ReportDate) AS MonthName,
    COUNT(*) AS IncidentCount
FROM dbo.FlyTipIncidents
GROUP BY
    MONTH(ReportDate),
    DATENAME(MONTH, ReportDate)
ORDER BY
    IncidentCount DESC;

    -- Weekend VS weekday 
    SELECT
    CASE
        WHEN DATEDIFF
        (
            DAY,
            '19000101',
            ReportDate
        ) % 7 IN (5, 6)
            THEN 'Weekend'
        ELSE 'Weekday'
    END AS DayCategory,
    COUNT(*) AS IncidentCount
FROM dbo.FlyTipIncidents
GROUP BY
    CASE
        WHEN DATEDIFF
        (
            DAY,
            '19000101',
            ReportDate
        ) % 7 IN (5, 6)
            THEN 'Weekend'
        ELSE 'Weekday'
    END
ORDER BY IncidentCount DESC;
/*---
Incident by time period 

---------------------------------------------------------------------------------------------*/
SELECT
    CASE
        WHEN ReportTime >= CAST('00:00:00' AS TIME)
         AND ReportTime <  CAST('06:00:00' AS TIME)
            THEN 'Night'

        WHEN ReportTime >= CAST('06:00:00' AS TIME)
         AND ReportTime <  CAST('12:00:00' AS TIME)
            THEN 'Morning'

        WHEN ReportTime >= CAST('12:00:00' AS TIME)
         AND ReportTime <  CAST('18:00:00' AS TIME)
            THEN 'Afternoon'

        ELSE 'Evening'
    END AS TimePeriod,

    COUNT(*) AS IncidentCount
FROM dbo.FlyTipIncidents
WHERE ReportTime IS NOT NULL
GROUP BY
    CASE
        WHEN ReportTime >= CAST('00:00:00' AS TIME)
         AND ReportTime <  CAST('06:00:00' AS TIME)
            THEN 'Night'

        WHEN ReportTime >= CAST('06:00:00' AS TIME)
         AND ReportTime <  CAST('12:00:00' AS TIME)
            THEN 'Morning'

        WHEN ReportTime >= CAST('12:00:00' AS TIME)
         AND ReportTime <  CAST('18:00:00' AS TIME)
            THEN 'Afternoon'

        ELSE 'Evening'
    END
ORDER BY
    IncidentCount DESC;




/*--------------------------------------------------------------------------------------
    Q8 — Cases with strong evidence
    ----------------------------------------------------------------------------------------*/

    SELECT
    c.CaseID,
    c.IncidentID,
    f.ReportDate,
    f.IncidentDate,
    f.CouncilID,
    f.LocationID,
    c.Officer,
    c.Evidence,
    c.VehiclaeIdentified,
    f.CCTVAvailable,
    c.SuspectIdentified,
    c.Action,
    c.Outcome
FROM dbo.FactInforcementCases AS c
INNER JOIN dbo.FlyTipIncidents AS f
    ON c.IncidentID = f.IncidentID
WHERE f.CCTVAvailable = 'Yes'
  AND c.VehiclaeIdentified = 'Yes'
  AND c.Evidence = 'Yes'
ORDER BY
    f.ReportDate DESC,
    c.CaseID;

    /*--------------------------------------------------------------------------
Q9 - Rank strong cases with score 
-------------------------------------------------------------------------------- */
SELECT
    c.CaseID,
    c.IncidentID,
    c.Officer,
    f.CCTVAvailable,
    c.VehiclaeIdentified,
    c.Evidence,
    c.SuspectIdentified,
    c.Action,
    c.Outcome,

    (
        CASE WHEN f.CCTVAvailable = 'Yes' THEN 1 ELSE 0 END
        +
        CASE WHEN c.VehiclaeIdentified = 'Yes' THEN 1 ELSE 0 END
        +
        CASE WHEN c.Evidence = 'Yes' THEN 1 ELSE 0 END
        +
        CASE WHEN c.SuspectIdentified = 'Yes' THEN 1 ELSE 0 END
    ) AS EvidenceScore
FROM dbo.FactInforcementCases AS c
INNER JOIN dbo.FlyTipIncidents AS f
    ON c.IncidentID = f.IncidentID
WHERE f.CCTVAvailable = 'Yes'
  AND c.VehiclaeIdentified = 'Yes'
  AND c.Evidence = 'Yes'
ORDER BY
    EvidenceScore DESC,
    c.CaseID;



/*--------------------------------------------------------------------------
Q10 - Repeat-offender intelligence profile 
-------------------------------------------------------------------------------- */
WITH SyntheticOffenderBase AS
(
    SELECT
        f.IncidentID,
        f.ReportDate,
        f.CouncilID,
        f.LocationID,
        f.WasteTypeID,

        CONCAT
        (
            'OFF-',
            f.CouncilID,
            '-',
            f.LocationID,
            '-',
            f.WasteTypeID,
            '-',
            RIGHT
            (
                '00'
                + CAST
                (
                    (
                        TRY_CONVERT
                        (
                            INT,
                            REPLACE(f.IncidentID, 'FT', '')
                        ) % 20
                    ) + 1
                    AS VARCHAR(2)
                ),
                2
            )
        ) AS OffenderID

    FROM dbo.FlyTipIncidents AS f
),
EvidenceByIncident AS
(
    SELECT
        IncidentID,
        COUNT(*) AS EvidenceCount
    FROM dbo.FactIntelligenceReport
    WHERE Reliability = 'High'
       OR IntelligenceGap <> 'None'
    GROUP BY IncidentID
),
EnforcementByIncident AS
(
    SELECT
        IncidentID,
        COUNT(*) AS EnforcementActions
    FROM dbo.FactInforcementCases
    GROUP BY IncidentID
),
OffenderProfile AS
(
    SELECT
        b.OffenderID,

        COUNT(*) AS IncidentCount,

        COUNT(DISTINCT b.CouncilID) AS CouncilsAffected,

        COUNT(DISTINCT b.WasteTypeID) AS WasteTypeCount,

        MAX(b.ReportDate) AS LastKnownIncident,

        SUM(ISNULL(e.EvidenceCount, 0)) AS EvidenceCount,

        SUM(ISNULL(x.EnforcementActions, 0)) AS EnforcementActions

    FROM SyntheticOffenderBase AS b
    LEFT JOIN EvidenceByIncident AS e
        ON b.IncidentID = e.IncidentID
    LEFT JOIN EnforcementByIncident AS x
        ON b.IncidentID = x.IncidentID
    GROUP BY
        b.OffenderID
)
SELECT
    OffenderID,
    IncidentCount,
    CouncilsAffected,
    WasteTypeCount,
    LastKnownIncident,
    EvidenceCount,
    EnforcementActions
FROM OffenderProfile
WHERE IncidentCount >= 2
ORDER BY
    IncidentCount DESC,
    EvidenceCount DESC,
    LastKnownIncident DESC;

    /*--------------------------------------------------------------------------
Q11 - Repeat-offender intelligence (Include council and waste-type names)
-------------------------------------------------------------------------------- */
WITH SyntheticOffenderBase AS
(
    SELECT
        f.IncidentID,
        f.ReportDate,
        f.CouncilID,
        f.WasteTypeID,

        CONCAT
        (
            'OFF-',
            f.CouncilID,
            '-',
            f.LocationID,
            '-',
            f.WasteTypeID,
            '-',
            RIGHT
            (
                '00'
                + CAST
                (
                    (
                        TRY_CONVERT
                        (
                            INT,
                            REPLACE(f.IncidentID, 'FT', '')
                        ) % 20
                    ) + 1
                    AS VARCHAR(2)
                ),
                2
            )
        ) AS OffenderID

    FROM dbo.FlyTipIncidents AS f
),
OffenderSummary AS
(
    SELECT
        s.OffenderID,
        COUNT(*) AS IncidentCount,
        COUNT(DISTINCT s.CouncilID) AS CouncilsAffected,
        COUNT(DISTINCT s.WasteTypeID) AS WasteTypesCount,
        MAX(s.ReportDate) AS LastKnownIncident
    FROM SyntheticOffenderBase AS s
    GROUP BY s.OffenderID
    HAVING COUNT(*) >= 2
)
SELECT
    os.OffenderID,
    os.IncidentCount,
    os.CouncilsAffected,
    os.WasteTypesCount,
    os.LastKnownIncident,

    councils.CouncilNames,
    waste.WasteTypeNames

FROM OffenderSummary AS os

OUTER APPLY
(
    SELECT
        STRING_AGG(c.CouncilName, ', ')
        WITHIN GROUP (ORDER BY c.CouncilName) AS CouncilNames
    FROM
    (
        SELECT DISTINCT
            b.CouncilID
        FROM SyntheticOffenderBase AS b
        WHERE b.OffenderID = os.OffenderID
    ) AS distinct_councils
    INNER JOIN dbo.DimCouncil AS c
        ON distinct_councils.CouncilID = c.CouncilID
) AS councils

OUTER APPLY
(
    SELECT
        STRING_AGG(w.WasteType, ', ')
        WITHIN GROUP (ORDER BY w.WasteType) AS WasteTypeNames
    FROM
    (
        SELECT DISTINCT
            b.WasteTypeID
        FROM SyntheticOffenderBase AS b
        WHERE b.OffenderID = os.OffenderID
    ) AS distinct_waste_types
    INNER JOIN dbo.DimWasteType AS w
        ON distinct_waste_types.WasteTypeID = w.WasteTypeID
) AS waste

ORDER BY
    os.IncidentCount DESC,
    os.LastKnownIncident DESC;
   