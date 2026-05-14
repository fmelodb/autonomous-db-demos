
-- Obs: Crie um índice de cada vez

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
DROP INDEX candidates_onnx_hvi;

CREATE HYBRID VECTOR INDEX candidates_onnx_hvi
ON candidates(profile)
PARAMETERS('MODEL multilingual_e5_base VECTOR_IDXTYPE HNSW');

-- =====================================================================
-- ÍNDICE HYBRID VECTOR USING OCI GENAI
-- =====================================================================

-- cohere.embed-multilingual-v3.0
DROP INDEX candidates_cohere_hvi;

CREATE HYBRID VECTOR INDEX candidates_cohere_hvi
ON candidates(profile)
PARAMETERS('VECTORIZER OCIGENAI_COHERE_EMBED_PREF');

