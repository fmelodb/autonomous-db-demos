set linesize 200
set pages 1000
set long 1000000

-- =====================================================================
-- CREATE HYBRID VECTOR INDEX USING OCI GENAI EMBEDDINGS
-- =====================================================================
-- Choose betweem Resource Principal or User Credential approach for OCI GenAI access

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


DROP INDEX IF EXISTS candidates_onnx_hvi;
DROP INDEX IF EXISTS candidates_cohere_hvi;

CREATE HYBRID VECTOR INDEX candidates_cohere_hvi
ON candidates(profile)
PARAMETERS('VECTORIZER OCIGENAI_COHERE_EMBED_PREF');



-- =====================================================================
-- TEXT ONLY
-- =====================================================================
-- json output format
SELECT json_serialize(
  dbms_hybrid_vector.search(
    json_object(
      'hybrid_index_name' VALUE 'candidates_cohere_hvi',
      'text'   VALUE json_object('contains' VALUE 'Kubeflow AND Seldon'),
      'return' VALUE json_object(
                       'values' VALUE json_array('rowid', 'score', 'text_score', 'text_rank'),
                       'topN'   VALUE 3
                     )
      RETURNING JSON
    )
  ) PRETTY
) as result;

-- text only with table output format
SELECT jt.*, (select profile from candidates where rowid = jt.doc_rowid) as profile
FROM
   JSON_TABLE(
        dbms_hybrid_vector.search(
                json_object(
                    'hybrid_index_name' VALUE 'candidates_cohere_hvi',
                    'text'   VALUE json_object('contains' VALUE 'Kubeflow AND Seldon'),
                    'return' VALUE json_object(
                                    'values' VALUE json_array('rowid', 'score', 'text_score', 'text_rank'),
                                    'topN'   VALUE 3
                                    )
                    RETURNING JSON
                    )
            ),
        '$[*]' COLUMNS idx for ORDINALITY,
                doc_rowid         PATH '$.rowid',
                score      NUMBER PATH '$.score',                
                text_score NUMBER PATH '$.text_score',                
                text_rank  NUMBER PATH '$.text_rank'
    ) jt;

-- =====================================================================
-- VECTOR ONLY
-- =====================================================================
-- "search_vector" can be used instead of "search_text" if the client application 
-- generates the vector using the same embedding model used to create the index. 

-- json output format (using search_text)
SELECT json_serialize(
  dbms_hybrid_vector.search(
    json_object(
      'hybrid_index_name' VALUE 'candidates_cohere_hvi',
      'vector'   VALUE json_object('search_text' VALUE 'segurança de redes'),
      'return' VALUE json_object(
                       'values' VALUE json_array('rowid', 'score', 'vector_score', 'vector_rank', 'chunk_text'),
                       'topN'   VALUE 3
                     )
      RETURNING JSON
    )
  ) PRETTY
) as result;


-- json output format (using search_vector)
SELECT json_serialize(
  dbms_hybrid_vector.search(
    json_object(
      'hybrid_index_name' VALUE 'candidates_cohere_hvi',
      'vector'   VALUE json_object('search_vector' 
                                    VALUE VECTOR_SERIALIZE(dbms_vector.utl_to_embedding(
                                        'segurança de redes',
                                        JSON('{
                                                "provider"        : "ocigenai",
                                                "credential_name" : "OCI_CRED",
                                                "url"             : "https://inference.generativeai.us-chicago-1.oci.oraclecloud.com/20231130/actions/embedText",            
                                                "model"           : "cohere.embed-multilingual-v3.0"
                                            }')
                                        )) returning json),
      'return' VALUE json_object(
                       'values' VALUE json_array('rowid', 'score', 'vector_score', 'vector_rank', 'chunk_text'),
                       'topN'   VALUE 3
                     )
      RETURNING JSON
    )
  ) PRETTY
) as result;

-- vector only with table output format
SELECT jt.*
FROM
   JSON_TABLE(
        dbms_hybrid_vector.search(
                json_object(
                    'hybrid_index_name' VALUE 'candidates_cohere_hvi',
                    'vector'   VALUE json_object('search_text' VALUE 'segurança de redes'),
                    'return' VALUE json_object(
                                    'values' VALUE json_array('rowid', 'score', 'vector_score', 'vector_rank', 'chunk_text'),
                                    'topN'   VALUE 3
                                    )
                    RETURNING JSON
                    )
            ),
        '$[*]' COLUMNS idx for ORDINALITY,
                doc_rowid         PATH '$.rowid',
                score        NUMBER PATH '$.score',                
                vector_score NUMBER PATH '$.vector_score',                
                vector_rank  NUMBER PATH '$.vector_rank',
                chunk_text   VARCHAR2(4000) PATH '$.chunk_text'
    ) jt;


-- =====================================================================
-- HYBRID VECTOR + TEXT
-- =====================================================================
-- json output format

SELECT json_serialize(
  dbms_hybrid_vector.search(
    json_object(
      'hybrid_index_name' VALUE 'candidates_cohere_hvi',      
      'search_fusion'     VALUE 'INTERSECT',
      'search_scorer'     VALUE 'rsf',
      'vector'            VALUE json_object('search_text' VALUE 'engenheiro de AI'), 
      'text'              VALUE json_object('contains'    VALUE 'SQL NOT PostgreSQL'),
      'return' VALUE json_object(
                       'values' VALUE json_array('rowid', 'score', 'vector_score', 'vector_rank', 'text_score', 'text_rank', 'chunk_text'),
                       'topN'   VALUE 3
                     )
      RETURNING JSON
    )
  ) PRETTY
) as result;


-- vector only with table output format
SELECT jt.*
FROM
   JSON_TABLE(
        dbms_hybrid_vector.search(
                json_object(
                  'hybrid_index_name' VALUE 'candidates_cohere_hvi',      
                  'search_fusion'     VALUE 'INTERSECT',
                  'search_scorer'     VALUE 'rsf',
                  'vector'            VALUE json_object('search_text' VALUE 'engenheiro de AI'), 
                  'text'              VALUE json_object('contains'    VALUE 'SQL NOT PostgreSQL'),
                  'return' VALUE json_object(
                                  'values' VALUE json_array('rowid', 'score', 'vector_score', 'vector_rank', 'text_score', 'text_rank', 'chunk_text'),
                                  'topN'   VALUE 3
                                )
                  RETURNING JSON
                )
            ),
        '$[*]' COLUMNS idx for ORDINALITY,
                doc_rowid         PATH '$.rowid',
                score        NUMBER PATH '$.score',                
                vector_score NUMBER PATH '$.vector_score',                
                vector_rank  NUMBER PATH '$.vector_rank',
                text_score   NUMBER PATH '$.text_score',
                text_rank    NUMBER PATH '$.text_rank',
                chunk_text   VARCHAR2(4000) PATH '$.chunk_text'
    ) jt;

