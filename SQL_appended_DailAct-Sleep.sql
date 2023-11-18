USE Bellabeat_DB
SELECT
	*
FROM
	dailyactivity AS A
INNER JOIN
	sleep AS S ON A.Id = S.Id
WHERE
	A.Date = S.DateLogged