
-- =====================================================================
-- OCI
-- =====================================================================

/********** 
Policy for Resource Principal

Identity & Security → Domains → Default → Dynamic Groups → Create:
 Domain: [you domain]
 ALL {resource.type='autonomousdatabase', resource.id='ocid1.autonomousdatabase.oc1.us-chicago-1.jncxe...'}

Identity & Security → Policies → Create Policy:
 Allow dynamic-group [group] to read buckets in compartment [compartment]
 Allow dynamic-group [group] to read objects in compartment [compartment]
 Allow dynamic-group [group] to manage objects in compartment [compartment]
 Allow dynamic-group [group] to manage object-family in compartment [compartment]
 Allow dynamic-group [group] to use generative-ai-family in compartment [compartment]

*************/


-- =====================================================================
-- Run as ADMIN
-- =====================================================================

CREATE USER vector_user IDENTIFIED BY "your_password";
GRANT EXECUTE ON DBMS_CRYPTO TO vector_user;
GRANT EXECUTE ON DBMS_CLOUD TO vector_user;
GRANT EXECUTE ON DBMS_CLOUD_AI TO vector_user;
GRANT EXECUTE ON DBMS_VECTOR_CHAIN TO vector_user;
GRANT DB_DEVELOPER_ROLE TO vector_user;

BEGIN
  DBMS_CLOUD_ADMIN.ENABLE_RESOURCE_PRINCIPAL();
END;
/

BEGIN
  DBMS_CLOUD_ADMIN.ENABLE_RESOURCE_PRINCIPAL(username => 'VECTOR_USER');
END;
/

-- change username
BEGIN
  DBMS_NETWORK_ACL_ADMIN.APPEND_HOST_ACE(
    host => '*.oraclecloud.com',
    ace  => xs$ace_type(
      privilege_list => xs$name_list('connect', 'http', 'http_proxy'),
      principal_name => 'VECTOR_USER',
      principal_type => xs_acl.ptype_db));
END;
/


