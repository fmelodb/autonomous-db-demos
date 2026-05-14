
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

SELECT VECTOR_EMBEDDING(
        MULTILINGUAL_E5_BASE 
        USING 'la veloce volpe marrone saltò' as DATA) 
    AS embedding;