-- PL/SQL function that runs an arbitrary SELECT with pagination
CREATE OR REPLACE FUNCTION run_sql(
    query  IN CLOB,
    offset IN NUMBER,
    limit  IN NUMBER
) RETURN CLOB AS
    v_sql  CLOB;
    v_json CLOB;
BEGIN
    v_sql := 'SELECT NVL(JSON_ARRAYAGG(JSON_OBJECT(*) RETURNING CLOB), ''[]'') AS json_output '
          || 'FROM ( '
          || '  SELECT * FROM ( ' || query || ' ) sub_q '
          || '  OFFSET :off ROWS FETCH NEXT :lim ROWS ONLY '
          || ')';
    EXECUTE IMMEDIATE v_sql INTO v_json USING offset, limit;
    RETURN v_json;
END;
/

-- Register the tool
BEGIN
  DBMS_CLOUD_AI_AGENT.CREATE_TOOL(
    tool_name  => 'MY_RUN_SQL_TOOL',
    attributes => '{
      "instruction": "This tool runs the provided read-only (SELECT) SQL query.",
      "function": "RUN_SQL",
      "tool_inputs": [
        {"name":"QUERY","description":"SELECT SQL statement without trailing semicolon."},
        {"name":"OFFSET","description":"Pagination parameter. Use this to set the page size when performing paginated data retrieval."},
        {"name":"LIMIT","description":"Pagination parameter. Use this to specify which page to fetch by skipping records before applying the limit."}
      ]
    }'
  );
END;
/

SELECT tool_name, description, status FROM USER_AI_AGENT_TOOLS;   


