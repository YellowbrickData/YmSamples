CREATE SCHEMA IF NOT EXISTS "healthcare";
GRANT ALL ON SCHEMA "healthcare" TO public;
SET SEARCH_PATH TO "healthcare";

CREATE EXTERNAL STORAGE "healthcare"."healthcare_storage" TYPE s3 ENDPOINT 'https://s3.amazonaws.com' REGION 'us-east-1';

CREATE EXTERNAL FORMAT "healthcare"."healthcare_format" TYPE csv;

CREATE EXTERNAL LOCATION "healthcare"."healthcare_location" PATH 'yb-sampledata-d4f1c23ea7' EXTERNAL STORAGE "healthcare"."healthcare_storage" EXTERNAL FORMAT "healthcare"."healthcare_format";

CREATE TABLE healthcare.patients (
    id uuid NOT NULL,
    birth_date date,
    death_date date,
    ssn character varying(11),
    drivers character varying(25),
    passport character varying(25),
    prefix character varying(25),
    first_name character varying(50),
    last_name character varying(50),
    suffix character varying(50),
    maiden_name character varying(50),
    marital_status character varying(10),
    race character varying(25),
    ethnicity character varying(25),
    gender character varying(10),
    birthplace character varying(250),
    address character varying(250),
    city character varying(250),
    state character varying(20),
    county character varying(50),
    zip character varying(10),
    lat character varying(25),
    lon character varying(25),
    healthcare_expenses numeric(15,2),
    healthcare_coverage numeric(15,2),
    CONSTRAINT "patients_pk" PRIMARY KEY (id)
)
DISTRIBUTE ON (id);

CREATE TABLE healthcare.organizations (
    id uuid NOT NULL,
    org_name character varying(250),
    address character varying(250),
    city character varying(250),
    state character varying(20),
    zip character varying(10),
    lat character varying(25),
    lon character varying(25),
    phone character varying(250),
    revenue character varying(250),
    utilization integer,
    CONSTRAINT "organizations_pk" PRIMARY KEY (id)
)
DISTRIBUTE RANDOM;

CREATE TABLE healthcare.payers (
    id uuid NOT NULL,
    payers_name character varying(250),
    address character varying(250),
    city character varying(50),
    state_headquartered character varying(2),
    zip character varying(5),
    phone character varying(25),
    amount_covered numeric(15,2),
    amount_uncovered numeric(15,2),
    revenue numeric(15,2),
    covered_encounters integer,
    uncovered_encounters integer,
    covered_medications integer,
    uncovered_medications integer,
    covered_procedures integer,
    uncovered_procedures integer,
    covered_immunizations integer,
    uncovered_immunizations integer,
    unique_customers integer,
    qols_avg numeric(18,0),
    member_months integer,
    CONSTRAINT "payer_pk" PRIMARY KEY (id)
)
DISTRIBUTE ON (id);

CREATE TABLE healthcare.providers (
    id uuid NOT NULL,
    organization uuid NOT NULL,
    org_name character varying(250),
    gender character varying(10),
    speciality character varying(250),
    address character varying(250),
    city character varying(250),
    state character varying(10),
    zip character varying(10),
    lat character varying(25),
    lon character varying(25),
    utilization integer,
    CONSTRAINT "providers_fk1" FOREIGN KEY (organization) REFERENCES healthcare.organizations(id),
    CONSTRAINT "providers_pk" PRIMARY KEY (id)
)
DISTRIBUTE ON (id);

CREATE TABLE healthcare.payer_transitions (
    patient uuid NOT NULL,
    start_year integer,
    end_year integer,
    payer uuid NOT NULL,
    ownership character varying(25),
    CONSTRAINT "payer_transitions_fk1" FOREIGN KEY (patient) REFERENCES healthcare.patients(id),
    CONSTRAINT "procedures_fk1" FOREIGN KEY (payer) REFERENCES healthcare.payers(id)
)
DISTRIBUTE RANDOM;

CREATE TABLE healthcare.encounters (
    id uuid NOT NULL,
    start_tmsp timestamp without time zone,
    stop_tmsp timestamp without time zone,
    patient uuid NOT NULL,
    organization uuid NOT NULL,
    provider uuid NOT NULL,
    payer uuid NOT NULL,
    encounterclass character varying(50),
    code character varying(50),
    description character varying(250),
    base_encounter_cost numeric(15,2),
    total_claim_cost numeric(15,2),
    payer_coverage numeric(15,2),
    reasoncode character varying(50),
    reasondescription character varying(250),
    CONSTRAINT "conditions_fk1" FOREIGN KEY (patient) REFERENCES healthcare.patients(id),
    CONSTRAINT "conditions_fk2" FOREIGN KEY (organization) REFERENCES healthcare.organizations(id),
    CONSTRAINT "conditions_fk3" FOREIGN KEY (provider) REFERENCES healthcare.providers(id),
    CONSTRAINT "conditions_fk4" FOREIGN KEY (payer) REFERENCES healthcare.payers(id),
    CONSTRAINT "encounters_fk2" FOREIGN KEY (organization) REFERENCES healthcare.organizations(id),
    CONSTRAINT "encounters_fk3" FOREIGN KEY (provider) REFERENCES healthcare.providers(id),
    CONSTRAINT "encounters_pk" PRIMARY KEY (id)
)
DISTRIBUTE ON (patient);

CREATE TABLE healthcare.allergies (
    start_date date,
    stop_date date,
    patient uuid NOT NULL,
    encounter uuid NOT NULL,
    code character varying(50),
    description character varying(250),
    CONSTRAINT "allergies_fk2" FOREIGN KEY (encounter) REFERENCES healthcare.encounters(id),
    CONSTRAINT "allergies_pk1" FOREIGN KEY (patient) REFERENCES healthcare.patients(id)
)
DISTRIBUTE ON (patient);

CREATE TABLE healthcare.careplans (
    id uuid,
    start_date date,
    stop_date date,
    patient uuid NOT NULL,
    encounter uuid NOT NULL,
    code character varying(50),
    description character varying(250),
    reasoncode character varying(50),
    reasondescription character varying(250),
    CONSTRAINT "careplans_fk1" FOREIGN KEY (patient) REFERENCES healthcare.patients(id),
    CONSTRAINT "careplans_fk2" FOREIGN KEY (encounter) REFERENCES healthcare.encounters(id)
)
DISTRIBUTE ON (patient);

CREATE TABLE healthcare.conditions (
    start_date date,
    stop_date date,
    patient uuid NOT NULL,
    encounter uuid NOT NULL,
    code character varying(50),
    description character varying(250),
    CONSTRAINT "conditions_fk1" FOREIGN KEY (patient) REFERENCES healthcare.patients(id),
    CONSTRAINT "conditions_fk2" FOREIGN KEY (encounter) REFERENCES healthcare.encounters(id)
)
DISTRIBUTE ON (patient);

CREATE TABLE healthcare.devices (
    start_date timestamp without time zone,
    stop_date timestamp without time zone,
    patient uuid NOT NULL,
    encounter uuid NOT NULL,
    code character varying(50),
    description character varying(250),
    device_id character varying(100),
    CONSTRAINT "devices_pk1" FOREIGN KEY (patient) REFERENCES healthcare.patients(id),
    CONSTRAINT "devices_pk2" FOREIGN KEY (encounter) REFERENCES healthcare.encounters(id)
)
DISTRIBUTE ON (patient);

CREATE TABLE healthcare.imaging_studies (
    id uuid NOT NULL,
    image_date timestamp without time zone,
    patient uuid NOT NULL,
    encounter uuid NOT NULL,
    bodysite_code character varying(50),
    bodysite_description character varying(250),
    modality_code character varying(50),
    modality_description character varying(250),
    sop_code character varying(50),
    sop_description character varying(250),
    CONSTRAINT "imaging_studies_fk1" FOREIGN KEY (patient) REFERENCES healthcare.patients(id),
    CONSTRAINT "imaging_studies_fk2" FOREIGN KEY (encounter) REFERENCES healthcare.encounters(id),
    CONSTRAINT "imaging_studies_pk" PRIMARY KEY (id)
)
DISTRIBUTE ON (patient);

CREATE TABLE healthcare.immunizations (
    immunization_date timestamp without time zone,
    patient uuid NOT NULL,
    encounter uuid NOT NULL,
    code character varying(50),
    description character varying(250),
    base_cost numeric(15,2),
    CONSTRAINT "immunizations_fk1" FOREIGN KEY (patient) REFERENCES healthcare.patients(id),
    CONSTRAINT "immunizations_fk2" FOREIGN KEY (encounter) REFERENCES healthcare.encounters(id)
)
DISTRIBUTE ON (patient);

CREATE TABLE healthcare.medications (
    start_date timestamp without time zone,
    stop_date timestamp without time zone,
    patient uuid NOT NULL,
    payer uuid NOT NULL,
    encounter uuid NOT NULL,
    code character varying(50),
    description character varying(250),
    base_cost numeric(15,2),
    payer_coverage numeric(15,2),
    dispenses numeric(15,2),
    totalcost numeric(15,2),
    reasoncode character varying(50),
    reasondescription character varying(250),
    CONSTRAINT "medications_fk1" FOREIGN KEY (patient) REFERENCES healthcare.patients(id),
    CONSTRAINT "medications_fk2" FOREIGN KEY (payer) REFERENCES healthcare.payers(id),
    CONSTRAINT "medications_fk3" FOREIGN KEY (encounter) REFERENCES healthcare.encounters(id)
)
DISTRIBUTE ON (patient);

CREATE TABLE healthcare.observations (
    obs_date timestamp without time zone,
    patient uuid,
    encounter uuid,
    code character varying(50),
    description character varying(250),
    value character varying(50),
    units character varying(50),
    type character varying(50),
    CONSTRAINT "observations_fk1" FOREIGN KEY (patient) REFERENCES healthcare.patients(id),
    CONSTRAINT "observations_fk2" FOREIGN KEY (encounter) REFERENCES healthcare.encounters(id)
)
DISTRIBUTE ON (patient);

CREATE TABLE healthcare.procedures (
    procedure_date timestamp without time zone,
    patient uuid NOT NULL,
    encounter uuid NOT NULL,
    code character varying(25),
    description character varying(250),
    base_cost numeric(15,2),
    reasoncode character varying(25),
    reasondescription character varying(250),
    CONSTRAINT "procedures_fk1" FOREIGN KEY (patient) REFERENCES healthcare.patients(id),
    CONSTRAINT "procedures_fk2" FOREIGN KEY (encounter) REFERENCES healthcare.encounters(id),
    CONSTRAINT "procedures_fk3" FOREIGN KEY (patient) REFERENCES healthcare.patients(id)
)
DISTRIBUTE ON (patient);

CREATE TABLE healthcare.supplies (
    supply_date date,
    patient uuid NOT NULL,
    encounter uuid NOT NULL,
    code character varying(25),
    description character varying(250),
    quantity integer,
    CONSTRAINT "supplies_fk1" FOREIGN KEY (patient) REFERENCES healthcare.patients(id),
    CONSTRAINT "supplies_fk2" FOREIGN KEY (encounter) REFERENCES healthcare.encounters(id)
)
DISTRIBUTE ON (patient);


LOAD TABLE "healthcare"."allergies" FROM ('/healthcare/allergies') EXTERNAL LOCATION "healthcare"."healthcare_location" EXTERNAL FORMAT "healthcare"."healthcare_format" WITH (max_bad_rows '100', num_readers '30', read_sources_concurrently 'ALWAYS');

LOAD TABLE "healthcare"."careplans" FROM ('/healthcare/careplans') EXTERNAL LOCATION "healthcare"."healthcare_location" EXTERNAL FORMAT "healthcare"."healthcare_format" WITH (max_bad_rows '100', num_readers '30', read_sources_concurrently 'ALWAYS');

LOAD TABLE "healthcare"."conditions" FROM ('/healthcare/conditions') EXTERNAL LOCATION "healthcare"."healthcare_location" EXTERNAL FORMAT "healthcare"."healthcare_format" WITH (max_bad_rows '100', num_readers '30', read_sources_concurrently 'ALWAYS');

LOAD TABLE "healthcare"."devices" FROM ('/healthcare/devices') EXTERNAL LOCATION "healthcare"."healthcare_location" EXTERNAL FORMAT "healthcare"."healthcare_format" WITH (max_bad_rows '100', num_readers '30', read_sources_concurrently 'ALWAYS');

LOAD TABLE "healthcare"."encounters" FROM ('/healthcare/encounters') EXTERNAL LOCATION "healthcare"."healthcare_location" EXTERNAL FORMAT "healthcare"."healthcare_format" WITH (max_bad_rows '100', num_readers '30', read_sources_concurrently 'ALWAYS');

LOAD TABLE "healthcare"."imaging_studies" FROM ('/healthcare/imaging_studies') EXTERNAL LOCATION "healthcare"."healthcare_location" EXTERNAL FORMAT "healthcare"."healthcare_format" WITH (max_bad_rows '100', num_readers '30', read_sources_concurrently 'ALWAYS');

LOAD TABLE "healthcare"."immunizations" FROM ('/healthcare/immunizations') EXTERNAL LOCATION "healthcare"."healthcare_location" EXTERNAL FORMAT "healthcare"."healthcare_format" WITH (max_bad_rows '100', num_readers '30', read_sources_concurrently 'ALWAYS');

LOAD TABLE "healthcare"."medications" FROM ('/healthcare/medications') EXTERNAL LOCATION "healthcare"."healthcare_location" EXTERNAL FORMAT "healthcare"."healthcare_format" WITH (max_bad_rows '100', num_readers '30', read_sources_concurrently 'ALWAYS');

LOAD TABLE "healthcare"."observations" FROM ('/healthcare/observations') EXTERNAL LOCATION "healthcare"."healthcare_location" EXTERNAL FORMAT "healthcare"."healthcare_format" WITH (max_bad_rows '100', num_readers '30', read_sources_concurrently 'ALWAYS');

LOAD TABLE "healthcare"."organizations" FROM ('/healthcare/organizations') EXTERNAL LOCATION "healthcare"."healthcare_location" EXTERNAL FORMAT "healthcare"."healthcare_format" WITH (max_bad_rows '100', num_readers '30', read_sources_concurrently 'ALWAYS');

LOAD TABLE "healthcare"."patients" FROM ('/healthcare/patients') EXTERNAL LOCATION "healthcare"."healthcare_location" EXTERNAL FORMAT "healthcare"."healthcare_format" WITH (max_bad_rows '100', num_readers '30', read_sources_concurrently 'ALWAYS');

LOAD TABLE "healthcare"."payer_transitions" FROM ('/healthcare/payer_transitions') EXTERNAL LOCATION "healthcare"."healthcare_location" EXTERNAL FORMAT "healthcare"."healthcare_format" WITH (max_bad_rows '100', num_readers '30', read_sources_concurrently 'ALWAYS');

LOAD TABLE "healthcare"."payers" FROM ('/healthcare/payers') EXTERNAL LOCATION "healthcare"."healthcare_location" EXTERNAL FORMAT "healthcare"."healthcare_format" WITH (max_bad_rows '100', num_readers '30', read_sources_concurrently 'ALWAYS');

LOAD TABLE "healthcare"."procedures" FROM ('/healthcare/procedures') EXTERNAL LOCATION "healthcare"."healthcare_location" EXTERNAL FORMAT "healthcare"."healthcare_format" WITH (max_bad_rows '100', num_readers '30', read_sources_concurrently 'ALWAYS');

LOAD TABLE "healthcare"."providers" FROM ('/healthcare/providers') EXTERNAL LOCATION "healthcare"."healthcare_location" EXTERNAL FORMAT "healthcare"."healthcare_format" WITH (max_bad_rows '100', num_readers '30', read_sources_concurrently 'ALWAYS');

LOAD TABLE "healthcare"."supplies" FROM ('/healthcare/supplies') EXTERNAL LOCATION "healthcare"."healthcare_location" EXTERNAL FORMAT "healthcare"."healthcare_format" WITH (max_bad_rows '100', num_readers '30', read_sources_concurrently 'ALWAYS');

