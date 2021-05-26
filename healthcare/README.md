# Healthcare Sample Dataset 

This is a set of randomly generated healthcare records, stored in FHIR v4 
format.  FHIR (Fast Healthcare Interoperability Resources) is an emerging 
standard for exchanging health care records electronically, while maintaining 
HIPAA compliance. 

These records were generated using an open-source software package called 
Synthea.  Synthea is a synthetic patient generator that models the medical 
history of synthetic patients.  It provides high-quality, synthetic, realistic 
but not real, patient data and associated health records, which are free from 
cost, privacy, and security restrictions, enabling research with Health IT data 
that is otherwise legally or practically unavailable.

These records are typically stored in either JSON or XML format, however they 
can also be stored in a relational format so that they can be analyzed at scale
by a data warehouse.


### Source

 * Website: http://hl7.org/fhir/
 * Website: https://synthetichealth.github.io/synthea/

### Tables

 1. **healthcare.patients**: A table of patients.
 2. **healthcare.encounters**: Patient encounters, such as hospital and office visits. 
 3. **healthcare.observations**: Medical observations, such as vital signs and lab reports.  
 4. **healthcare.procedures**: Patient procedures, such as surgeries. 
 5. **healthcare.medications**: Medications that have been prescribed. 
 6. **healthcare.immunizations**: Immunization records.
 7. **healthcare.imaging_studies**: Medical imaging metadata, such as MRI results. 
 8. **healthcare.devices**: Medical devices used on the patient during an encounter. 
 9. **healthcare.conditions**: History of medical conditions. 
 10. **healthcare.allergies**: List of allergies for each patient. 
 11. **healthcare.careplans**: Patient care plan data, including goals. 
 12. **healthcare.payer_transitions**: Changes in health insurance. 
 13. **healthcare.providers**: Clinicians that provide patient care. 
 14. **healthcare.payers**: Payer organization data. 
 15. **healthcare.organizations**: Provider organizations, such as hospitals and clinics. 
 16. **healthcare.supplies**: Supplies used during each encounter. 

### References

 http://hl7.org/fhir/
 https://synthetichealth.github.io/synthea/

### Samples

  Here is a sample query that lists the top 100 destination IPs for SSH traffic. 


