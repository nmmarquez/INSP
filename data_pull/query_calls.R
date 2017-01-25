read_creds <- function(){
    read.csv(paste0(paste0(dirname(sys.frame(1)$ofile), "/../.creds.csv")),
             stringsAsFactors=FALSE)
}

query_wrapper <- function(query, db="cod-dbsnapshot-d01.ihme.washington.edu"){
    cred_df <- read_creds()
    con <- dbConnect(MySQL(), user=cred_df$usr, password=cred_df$pw, host=db)
    res <- dbSendQuery(con, query)
    df <- fetch(res, n=-1)
    dbDisconnect(dbListConnections(MySQL())[[1]])
    df
}

mort_call <- "
SELECT 
    o.location_id,
    o.age_group_id,
    o.year_id,
    o.sex_id,
    o.mean_pop as population,
    o.mean_env_hivdeleted as envelope_HIVD
FROM
    mortality.output o
INNER JOIN mortality.output_version ov ON
    o.output_version_id = ov.output_version_id
WHERE
    ov.is_best = 1
AND
    o.location_id IN ( # only pull from mexico states
        SELECT location_id FROM shared.location_hierarchy_history
        WHERE location_set_version_id = 75 AND parent_id = 130);
"

cod_call_raw <- "
SELECT 
    cmd.data_version_id,
    cmd.cause_id,
    cmd.year_id,
    cmd.age_group_id,
    cmd.sex_id,
    cmd.location_id,
    cmd.cf_final,
    cmd.cf_raw,
    cmdv.nid, 
    cmdv.source,
    lhh.location_name,
    cn.cause_name
FROM
    cod.cm_data cmd
INNER JOIN cod.cm_data_version cmdv ON
    cmd.data_version_id = cmdv.data_version_id
INNER JOIN shared.location_hierarchy_history lhh ON
    cmd.location_id = lhh.location_id
INNER JOIN shared.cause cn ON
    cmd.cause_id = cn.cause_id
WHERE
    lhh.location_set_version_id = 75 
    AND lhh.parent_id = 130 # only pull from mexico states
    AND cmd.cause_id IN ({});
"

cause_list_call <- "
SELECT cause_id, acause, cause_name, is_estimate
FROM shared.cause_hierarchy_history
WHERE cause_set_version_id = 96; # last gbd estimation cause list for 2015
"

