--Q1 
--A--
SELECT
	npi,
	SUM(total_claim_count) AS grand_total
FROM prescriber INNER JOIN prescription USING(npi)
				GROUP BY npi
				ORDER BY grand_total DESC
				LIMIT 1;
	--ans: 1881634483 with 99707 total claims
SELECT prescription.npi AS Prescp_npi, prescriber.npi AS prescb_npi, total_claim_count
FROM prescription 
LEFT JOIN prescriber ON prescription.npi = prescriber.npi
ORDER BY total_claim_count DESC;
--B--
SELECT prescription.npi AS Prescp_npi,
prescriber.npi AS prescb_npi, total_claim_count, nppes_provider_first_name, nppes_provider_last_org_name,
specialty_description, SUM(total_claim_count) AS grand_total
FROM prescriber INNER JOIN prescription USING (npi) 
	GROUP BY npi, nppes_provider_first_name, 


--Q2--
--a--
SELECT specialty_description, SUM(total_claim_count) AS grand_total
FROM prescriber INNER JOIN prescription USING (npi)
GROUP BY specialty_description
ORDER BY grand_total DESC
LIMIT 1 ;

--b--
SELECT specialty_description, SUM(total_claim_count) AS grand_total
FROM prescriber INNER JOIN prescription USING (npi)
				LEFT JOIN drug USING(drug_name)
WHERE opioid_drug_flag = 'Y'
GROUP BY specialty_description
ORDER BY grand_total DESC
LIMIT 1;

--c--
SELECT specialty_description, SUM(total_claim_count)
FROM prescriber LEFT JOIN prescription USING (npi)
GROUP BY specialty_description
HAVING SUM(total_claim_count) IS NULL;

--d--
SELECT specialty_description, 
		SUM(CASE WHEN opioid_drug_flag = 'Y' THEN total_claim_count END)  
		/ SUM(total_claim_count) * 100 AS per_opioid_claims
FROM prescriber INNER JOIN prescription USING (npi)
				LEFT JOIN drug USING(drug_name)
GROUP BY specialty_description
ORDER BY per_opioid_claims DESC NULLS LAST;

--Q3--
--a--
SELECT generic_name, SUM(total_drug_cost):: money AS grand_total
FROM drug INNER JOIN prescription USING(drug_name)
GROUP BY generic_name
ORDER BY grand_total DESC
LIMIT 1;

--b--
SELECT generic_name, ROUND(SUM(total_drug_cost) / SUM(total_day_supply),2) AS avg_cost_per_day
FROM drug INNER JOIN prescription USING (drug_name)
GROUP BY generic_name
ORDER BY avg_cost_per_day DESC
LIMIT 1;

--Q4--
--a--
SELECT drug_name, 
		CASE WHEN opioid_drug_flag='Y' THEN 'opioid'
			 WHEN antibiotic_drug_flag = 'Y' THEN 'antibiotic'
			 ELSE 'neither' END AS drug_type
FROM drug;

--b--
WITH drug_types AS (SELECT drug_name, 
					 CASE WHEN opioid_drug_flag='Y' THEN 'opioid'
					 WHEN antibiotic_drug_flag = 'Y' THEN 'antibiotic'
					 ELSE 'neither' END AS drug_type
				FROM drug)
SELECT drug_type, SUM(total_drug_cost)::money AS total_cost
FROM drug_types INNER JOIN prescription USING (drug_name)
GROUP BY drug_type;

--Q5--
--a--
SELECT COUNT(DISTINCT cbsa)
FROM cbsa INNER JOIN fips_county USING (fipscounty)
WHERE state = 'TN';

--b--
SELECT cbsaname, SUM(population)AS total_pop
FROM cbsa INNER JOIN population USING (fipscounty)
GROUP BY cbsaname
ORDER BY total_pop;

--c--
SELECT county, population
FROM population INNER JOIN fips_county USING(fipscounty)
WHERE fipscounty NOT IN (SELECT DISTINCT fipscounty 
						 FROM cbsa)
ORDER BY population DESC;

--Q6--
--a--
SELECT drug_name, total_claim_count
FROM prescription
WHERE total_claim_count >= 3000;
--b--
SELECT drug_name, total_claim_count, opioid_drug_flag
FROM prescription INNER JOIN drug USING (drug_name) 
WHERE total_claim_count >= 3000;
--c--
SELECT drug_name, total_claim_count, opioid_drug_flag, 
		nppes_provider_first_name, nppes_provider_last_org_name
FROM prescription INNER JOIN drug USING (drug_name)
				  INNER JOIN prescriber USING (npi)
WHERE total_claim_count >=3000;

--Q7--
--a--
SELECT npi, drug_name
FROM prescriber CROSS JOIN drug --because there is no common coloumn ther is no need to use ON or USING--
WHERE specialty_description = 'Pain Management'
		AND nppes_provider_city = 'NASHVILLE'
		AND opioid_drug_flag = 'Y';	
--b--
SELECT prescriber.npi, drug_name, total_claim_count
FROM prescriber CROSS JOIN drug --because there is no common coloumn ther is no need to use ON or USING--
				LEFT JOIN prescription USING (npi, drug_name)
WHERE specialty_description = 'Pain Management'
		AND nppes_provider_city = 'NASHVILLE'
		AND opioid_drug_flag = 'Y'
ORDER BY npi;
		
--c--
SELECT npi, drug_name,
COALESCE(total_claim_count, 0) AS total_claims
FROM prescriber CROSS JOIN drug
				LEFT JOIN prescription USING (npi, drug_name)
WHERE specialty_description = 'Pain Management'
		AND nppes_provider_city = 'NASHVILLE'
		AND opioid_drug_flag = 'Y'
ORDER BY npi;
				

		
