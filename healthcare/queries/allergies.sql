-- Count the number of patients with each type of allergy.

select code, description, count(*) as num_patients from healthcare.allergies group by code, description order by num_patients desc;
