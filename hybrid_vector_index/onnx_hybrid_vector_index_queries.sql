set linesize 200
set pages 1000
set long 1000000

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

