
-- =====================================================================
-- Run as ADMIN
-- =====================================================================

GRANT EXECUTE ON DBMS_CRYPTO TO vector_user;
GRANT EXECUTE ON DBMS_CLOUD TO vector_user;
GRANT EXECUTE ON DBMS_CLOUD_AI TO vector_user;
GRANT EXECUTE ON DBMS_VECTOR_CHAIN TO vector_user;

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

-- =====================================================================
-- Run as VECTOR_USER
-- =====================================================================
-- Choose betweem Resource Principal or User Credential approach for OCI GenAI access (see below) and then create the hybrid vector index using the created preference (see 04_create_hybrid_index.sql)

-- Using OCI$RESOURCE_PRINCIPAL
EXEC DBMS_VECTOR_CHAIN.DROP_PREFERENCE(PREF_NAME => 'OCIGENAI_COHERE_EMBED_PREF');

BEGIN
  DBMS_VECTOR_CHAIN.CREATE_PREFERENCE(
    PREF_NAME => 'OCIGENAI_COHERE_EMBED_PREF',
    PREF_TYPE => DBMS_VECTOR_CHAIN.VECTORIZER,
    PARAMS    => JSON('{
      "embedder_spec": {
        "provider": "ocigenai",
        "url": "https://inference.generativeai.us-chicago-1.oci.oraclecloud.com/20231130/actions/embedText",
        "credential_name": "OCI$RESOURCE_PRINCIPAL",
        "model": "cohere.embed-multilingual-v3.0",
        "compartmentId"  : "ocid1.compartment.oc1..aaaaaaaa33ogmhasyvcqzuv...."            
      },
      "vector_idxtype": "HNSW",
      "by": "words",
      "max": 100,
      "overlap": 10,
      "split": "recursively"
    }')
  );
END;
/


-- Using user credential (uncomment if you want to use this approach instead of resource principal)
declare
  jo json_object_t;
begin
  jo := json_object_t();
  jo.put('user_ocid','ocid1.user.oc1..aaaaaaaaapiwklrpddpld...');
  jo.put('tenancy_ocid','ocid1.tenancy.oc1..aaaaaaaaoi6b5sx...');
  jo.put('compartment_ocid','ocid1.compartment.oc1..aaaaaaa...');
  jo.put('private_key','AIIEvGIBADBNBgkqhkiG9w0BAQEFAASCBKc...');
  jo.put('fingerprint','8c:ba:b9:19:fd:ce:16:2a:49:03:2d:45...');

  dbms_vector_chain.create_credential(
    credential_name   => 'OCI_CRED',
    params            => json(jo.to_string));
end;
/

BEGIN
  DBMS_VECTOR_CHAIN.CREATE_PREFERENCE(
    PREF_NAME => 'OCIGENAI_COHERE_EMBED_PREF',
    PREF_TYPE => DBMS_VECTOR_CHAIN.VECTORIZER,
    PARAMS    => JSON('{
      "embedder_spec": {
        "provider": "ocigenai",
        "url": "https://inference.generativeai.us-chicago-1.oci.oraclecloud.com/20231130/actions/embedText",
        "credential_name": "OCI_CRED",
        "model": "cohere.embed-multilingual-v3.0"            
      },
      "vector_idxtype": "HNSW",
      "by": "words",
      "max": 100,
      "overlap": 10,
      "split": "recursively"
    }')
  );
END;
/


