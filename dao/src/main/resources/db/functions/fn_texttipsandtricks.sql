CREATE OR REPLACE FUNCTION public.fn_texttipsandtricks(
    search_query text,
    language_code text)
    RETURNS TABLE(id bigint, creation_date timestamp with time zone, image_path character varying, author_id bigint, text character varying, title character varying, source character varying)
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE
    ROWS 1000
AS $BODY$
BEGIN
    RETURN QUERY
        SELECT DISTINCT tt.id,
                        tt.creation_date,
                        tt.image_path,tt.author_id,
                        title.content,
                        textTrans.content,
                        tt.source
        FROM tips_and_tricks tt
                 LEFT JOIN title_translations title
                           ON title.tips_and_tricks_id = tt.id
                 LEFT JOIN text_translations textTrans
                           ON textTrans.tips_and_tricks_id = tt.id
                 JOIN languages l
                      ON l.id = title.language_id
                          AND l.id = textTrans.language_id
        WHERE (
                    LOWER(title.content) LIKE LOWER(CONCAT('%', search_query, '%'))
                OR LOWER(textTrans.content) LIKE LOWER(CONCAT('%', search_query, '%'))
                OR tt.id IN (
                SELECT tt.id FROM tips_and_tricks tt
                                      JOIN tags ttt
                                           ON ttt.id = tt.id
                WHERE LOWER(ttt.name) LIKE LOWER(CONCAT('%', search_query, '%')))
            )
          AND l.code = language_code;

END
$BODY$;