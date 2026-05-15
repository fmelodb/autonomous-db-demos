set linesize 200
set pages 1000
set long 1000000

-- =====================================================================
-- IMPORT ONNX MODEL
-- =====================================================================

-- must load MULTILINGUAL_E5_BASE model before running this script
-- enable resource principal in the database and grant access to the bucket where the model is stored
-- get it from https://blogs.oracle.com/machinelearning/oml4py-leveraging-onnx-and-hugging-face-for-advanced-ai-vector-search

declare
    model_source blob := NULL;
begin
    model_source := dbms_cloud.get_object(
        credential_name => 'OCI$RESOURCE_PRINCIPAL',
        object_uri => 'url'
    ); 

    dbms_vector.load_onnx_model(
        'MULTILINGUAL_E5_BASE',
        model_source,
        metadata => JSON('{"function" : "embedding", "embeddingOutput" : "embedding", "input": {"input": ["DATA"]}}')
    );
END;
/

-- testing
SELECT VECTOR_EMBEDDING(
        MULTILINGUAL_E5_BASE 
        USING 'la veloce volpe marrone saltò' as DATA) 
    AS embedding;


-- =====================================================================
-- ÍNDICE HYBRID VECTOR IN-DATABASE
-- =====================================================================
-- Pré-requisito: modelo ONNX multilingual-e5-base já carregado em DBMS_VECTOR
-- Exemplo de load (executar uma vez):
--   EXEC DBMS_VECTOR.LOAD_ONNX_MODEL(
--     directory   => 'ONNX_DIR',
--     file_name   => 'multilingual-e5-base.onnx',
--     model_name  => 'multilingual_e5_base');

-- in-database (onnx format)
DROP INDEX IF EXISTS candidates_onnx_hvi;
DROP INDEX IF EXISTS candidates_cohere_hvi;

CREATE HYBRID VECTOR INDEX candidates_onnx_hvi
ON candidates(profile)
PARAMETERS('MODEL multilingual_e5_base VECTOR_IDXTYPE HNSW');

-- =====================================================================
-- TEXT ONLY
-- =====================================================================
-- json output format
SELECT json_serialize(
  dbms_hybrid_vector.search(
    json_object(
      'hybrid_index_name' VALUE 'candidates_onnx_hvi',
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
                    'hybrid_index_name' VALUE 'candidates_onnx_hvi',
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
      'hybrid_index_name' VALUE 'candidates_onnx_hvi',
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
      'hybrid_index_name' VALUE 'candidates_onnx_hvi',
      'vector'   VALUE json_object('search_vector' 
                                    VALUE vector_serialize(
                                            vector_embedding(MULTILINGUAL_E5_BASE 
                                               using 'segurança de redes' 
                                               as data)) returning JSON),
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
                    'hybrid_index_name' VALUE 'candidates_onnx_hvi',
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
      'hybrid_index_name' VALUE 'candidates_onnx_hvi',      
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
                  'hybrid_index_name' VALUE 'candidates_onnx_hvi',      
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

