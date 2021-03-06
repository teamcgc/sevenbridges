# 7. Misc

#' Opens browser to copy the auth token
#'
#' Click 'Generate Token' button, copy and paste the generated token
#' string to the R console. The function will return the token string.
#'
#' @return auth token
#'
#' @export misc_get_token
#' @importFrom utils browseURL
#' @examples
#' # Paste the auth token into R
#' # console then press enter:
#' token = NULL
#' \donttest{token = misc_get_token()}
misc_get_token = function () {

    browseURL('https://igor.sbgenomics.com/account/?current=developer#developer')
    cat("\nEnter the generated authentication token:")
    token = scan(what = character(), nlines = 1L, quiet = TRUE)

    return(token)

}

#' Download SBG uploader and extract to a specified directory
#'
#' Download SBG uploader and extract to a specified directory.
#'
#' @return \code{0L} if the SBG CLI uploader is successfully
#' downloaded and unarchived.
#'
#' @param destdir The directory to extract SBG uploader to.
#' If not present, it will be created automatically.
#'
#' @export misc_get_uploader
#' @importFrom utils untar download.file
#' @examples
#' dir = '~/sbg-uploader/'
#' \donttest{misc_get_uploader(dir)}
misc_get_uploader = function (destdir = NULL) {

    if (is.null(destdir)) stop('destdir must be provided')

    tmpfile = tempfile()

    download.file(url = 'https://igor.sbgenomics.com/sbg-uploader/sbg-uploader.tgz',
                  method = 'libcurl', destfile = tmpfile)

    untar(tarfile = tmpfile, exdir = path.expand(destdir))

}

#' Specify the parameters of the file metadata and return a list,
#' JSON string, or write to a file
#'
#' Specify the parameters of the file metadata and return a list,
#' JSON string, or write to a file.
#'
#' For more information about file metadata, please check the
#' File Metadata Documentation:
#' \url{https://developer.sbgenomics.com/platform/metadata}.
#'
#' @param output Output format,
#' could be \code{'list'}, \code{'json'}, or \code{'metafile'}.
#' @param destfile Filename to write to.
#' Must be specified when \code{output = 'metafile'}.
#' @param name File name.
#' @param file_type File type. This metadata parameter is mandatory
#' for each file.
#' @param qual_scale Quality scale encoding. For FASTQ files, you must
#' either specify the quality score encoding sch which contains the
#' FASTQ quality scale detector wrapper. In that case, you can
#' specify the quality score encoding scheme by setting
#' \code{qual_scale} inside the pipeline. For BAM files, this value
#' should always be \code{'sanger'}.
#' @param seq_tech Sequencing technology. The \code{seq_tech} parameter
#' allows you to specify the sequencing technology used. This metadata
#' parameter is only required by some the tools and pipelines; however,
#' it is strongly recommended that you set it whenever possible, unless
#' you are certain that your pipeline will work without it.
#' @param sample Sample ID. You can use the \code{sample} parameter to specify
#' the sample identifier. The value supplied in this field will be written
#' to the read group tag (\code{@@RG:SM}) in SAM/BAM files generated from reads
#' with the specified Sample ID. AddOrReplaceReadGroups will use this
#' parameter as the value for the read group tag in a SAM/BAM file.
#' @param library Library. You can set the library for the read using the
#' \code{library} parameter. The value supplied in this field will be written
#' to the read group tag (\code{@@RG:LB}) in SAM/BAM files generated from
#' reads with the specified Library ID. AddOrReplaceReadGroups will use
#' this parameter as the value for the read group tag in a SAM/BAM file.
#' @param platform_unit Platform unit. You can set the platform unit
#' (e.g. lane for Illumina, or slide for SOLiD) using the \code{platform_unit}
#' parameter. The value supplied in this field will be written to the read
#' group tag (\code{@@RG:PU}) in SAM/BAM files generated from the reads with
#' the specified Platform Unit. AddOrReplaceReadGroups will use this parameter
#' as the value for the read group tag of a SAM/BAM file.
#' @param paired_end Paired end. With paired-end reads, this parameter
#' indicates if the read file is left end (1) or right end (2).
#' For SOLiD CSFASTA files, paired end files 1 and 2 correspond to R3
#' and F3 files, respectively.
#'
#' @return list, JSON string, or a file.
#'
#' @export misc_make_metadata
#' @references
#' \url{https://developer.sbgenomics.com/platform/metadata}
#'
#' @examples
#' destfile = '~/c.elegans_chr2_test.fastq.meta'
#' \donttest{misc_make_metadata(output = 'metafile',
#'             destfile = destfile,
#'             name = 'c.elegans_chr2_test.fastq',
#'             file_type = 'fastq', qual_scale = 'illumina13',
#'             seq_tech = 'Illumina')}
misc_make_metadata = function (output = c('list', 'json', 'metafile'),
                               destfile = NULL,
                               name = NULL,
                               file_type = c('text', 'binary', 'fasta',
                                             'csfasta', 'fastq', 'qual',
                                             'xsq', 'sff', 'bam', 'bam_index',
                                             'illumina_export', 'vcf', 'sam',
                                             'bed', 'archive', 'juncs',
                                             'gtf','gff', 'enlis_genome'),
                               qual_scale = c('sanger', 'illumina13',
                                              'illumina15', 'illumina18',
                                              'solexa'),
                               seq_tech = c('454', 'Helicos', 'Illumina',
                                            'Solid', 'IonTorrent'),
                               sample = NULL, library = NULL,
                               platform_unit = NULL, paired_end = NULL) {

    body = list(list('file_type' = file_type,
                     'qual_scale' = qual_scale,
                     'seq_tech' = seq_tech))
    names(body) = 'metadata'

    if (!is.null(sample)) body$'metadata'$'sample' = as.character(sample)
    if (!is.null(library)) body$'metadata'$'library' = as.character(library)
    if (!is.null(platform_unit)) body$'metadata'$'platform_unit' = as.character(platform_unit)
    if (!is.null(paired_end)) body$'metadata'$'paired_end' = as.character(paired_end)

    if (!is.null(name)) body = c(list('name' = name), body)

    if (output == 'metafile') {
        if (is.null(destfile)) stop('destfile must be provided')
        body = toJSON(body, auto_unbox = TRUE)
        writeLines(body, con = destfile)
    } else if (output == 'json') {
        body = toJSON(body, auto_unbox = TRUE)
        return(body)
    } else if (output == 'list') {
        return(body)
    }

}

#' Upload files using SBG uploader
#'
#' Upload files using SBG uploader.
#'
#' @return The uploaded file's ID number.
#'
#' @param token auth token
#' @param uploader The directory where the SBG uploader is located
#' (the directory that contains the bin/ directory).
#' @param file The location of the file to upload.
#' @param project_id The project ID to upload the files to.
#' If you do not supply this, then the uploader will place the
#' incoming files in your "My Files" section.
#' @param proxy Allows you to specify a proxy server through which
#' the uploader should connect. About the details the proxy parameter format,
#' see \url{https://developer.sbgenomics.com/tools/uploader/documentation}.
#'
#' @export misc_upload_cli
#' @references
#' \url{https://developer.sbgenomics.com/tools/uploader/documentation}
#'
#' @examples
#' token = '420b4672ebfc43bab48dc0d18a32fb6f'
#' \donttest{misc_upload_cli(token = token,
#'                           uploader = '~/sbg-uploader/',
#'                           file = '~/example.fastq', project_id = '1234')}
misc_upload_cli = function (token = NULL, uploader = NULL,
                            file = NULL, project_id = NULL,
                            proxy = NULL) {

    if (is.null(token)) stop('token must be provided')
    if (is.null(uploader)) stop('SBG uploader location must be provided')
    if (is.null(file)) stop('File location must be provided')

    token = paste('-t', token)
    uploader = file.path(paste0(uploader, '/bin/sbg-uploader.sh'))
    file = file.path(file)

    if (!is.null(project_id)) project_id = paste('-p', project_id)
    if (!is.null(proxy)) proxy = paste('-x', proxy)

    cmd = paste(uploader, token, project_id, proxy, file)
    res = system(command = cmd, intern = TRUE)
    fid = strsplit(res, '\t')[[1]][1]
    return(fid)

}



.getFields <- function(x, values) {
    ## from Martin's code
    flds = names(x$getRefClass()$fields())
    if (!missing(values))
        flds = flds[flds %in% values]
    result = setNames(vector("list", length(flds)), flds)
    for (fld in flds){
        result[fld] = list(x[[fld]])
    }
    result
}



stopifnot_provided <- function(..., msg = "is not provided"){
    n <- length(ll <- list(...))
    if(n == 0)
        return(invisible())
    mc <- match.call()
    x = NULL
    for(i in 1:n){
        if(!(is.logical(r <- eval(ll[[i]])) && all(r))){
            l <- mc[[i+1]][[2]]
            x <- c(x, deparse(l[[length(l)]]))
        }
    }
    if(length(x))
        stop(paste(paste(x, collapse = ","), msg), call. = FALSE)
}




m.fun <- function(x, y, exact = TRUE, ignore.case = TRUE, ...){
    if(exact){
        pmatch(x, y, ...)
    }else{
        grep(x, y, ignore.case = ignore.case, ...)
    }
}

## match by id and name
m.match <- function(obj, id = NULL, name = NULL,
                    .id = "id",
                    .name = "name",
                    exact = TRUE, ignore.case = TRUE){
    ## if no match, return whole list
    if(is.null(id)){
        if(is.null(name)){
            if(length(obj) == 1){
                return(obj[[1]])
            }else{
                return(obj)                
            }

        }else{
            ## id is null, so use username
            nms <- sapply(obj, function(x) x[[.name]])
            if(ignore.case){
                name <- tolower(name)
                nms <- tolower(nms)
            }
            index <- m.fun(name, nms,
                           exact = exact,
                           ignore.case = ignore.case)
        }
    }else{
        ## id is not NULL
        ids <- sapply(obj, function(x) x[[.id]])
        index <- m.fun(id, ids,
                       exact = exact,
                       ignore.case = ignore.case)

    }
    if(length(index) == 1 && is.na(index)){
        message("sorry, no matching ")
        return(NULL)
    }else{

        if(length(index) ==1){
            obj[[index]]
        }else{
            obj[index]
        }
    }
}


.showFields <- function(x, title = NULL, values = NULL, full = FALSE){
    if (missing(values)){
        flds = names(x$getRefClass()$fields())
    }else{
        flds = values
    }

    if(!length(x))
        return(NULL)

    if(!full){
        idx <- sapply(flds, is.null)
        if(!is.null(title) && !all(idx)){
            message(title)
        }

        ## ugly, change later
        for (fld in flds[!idx]){
            if(is.list(x[[fld]])){
                if(length(x[[fld]])){
                    message(fld, ":")
                    .showList(x[[fld]], space =  "  ")
                }
            }else if(is(x[[fld]], "Item")){
                x[[fld]]$show()
            }else{
                if(is.character(x[[fld]])){
                    if(x[[fld]] != "" && length(x[[fld]])){
                        message(fld, " : ", paste0(x[[fld]], collapse = " "))
                    }
                }else{
                    if(!is.null(x[[fld]]) && length(x[[fld]]))
                        message(fld, " : ", x[[fld]])                                                           
                }
            }
        }

    }else{
        message(title)
        ## ugly, change later
        for (fld in flds){
            if(is.list(x[[fld]])){
                message(fld, ":")                
                .showList(x[[fld]], space =  "  ", full = full)
            }else if(is(x[[fld]], "Item")){
                x[[fld]]$show()
            }else{
                if(is.character(x[[fld]])){
                        message(fld, " : ", paste0(x[[fld]], collapse = " "))                                        
                }else{
                        message(fld, " : ", x[[fld]])                                                           
                }
            }
        }
        
    }
}

.showList <- function(x, space = "", full = FALSE){
    if(length(x)){
        if(!full){
            idx <- sapply(x, function(s){
                if(is.character(s)){
                    idx <- nchar(s)
                }else{
                    idx <- TRUE
                }
                !is.null(s) && idx
            })
            x <- x[idx]
        }
        for (fld in names(x)){
            if(all(is.character(x[[fld]]))){
                msg <- paste0(x[[fld]], collapse = " \n ")
                message(space, fld, " : ", msg)                                
            }else{
                if(is(x[[fld]], "Meta")){
                    msg <- as.character(x[[fld]]$data)
                }else{
                    msg <- as.character(x[[fld]])
                }
                message(space, fld, " : ", msg)                
            }
        }
    }
}


.update_list <- function(o, n){
    o.nm <- names(o)
    n.nm <- names(n)
    i.nm <- intersect(o.nm, n.nm)

    if(length(i.nm)){
        o.nm <- setdiff(o.nm, i.nm)
        c(o[o.nm], n)
    }else{
        c(o, n)
    }
}


## guess version based on URL and save it
.ver <- function(url){
    str_match(url, "https://.*/(.*)/$")[, 2]   
}


## parse an item from a v2 request object
parseItem <- function(x){
    obj <- x$items
    attr(obj, "href") <- x$href
    attr(obj, "response") <- x$response
    obj
}

hasItems <- function(x){
    "items" %in% names(x)
}

ptype <- function(x){
    ifelse(grepl("\\/", x), "v2", "1.1")
}


isv2 <- function(version){
    version == "v2"
}

v2Check <- function(version, msg = "This function only supported in API V2"){
    if(version != "v2")
        stop(msg,  call. = FALSE)
}



## a quick fix for List class
Item0 <- setClass("Item0", slots = list(href = "characterORNULL",
                               response = "ANY"))


## a function from cwl.R, avoid import for some unknown problem on roxygen2

#' List Class generator.
#'
#' Extends IRanges SimpleList class and return constructor.
#' 
#' @param elementType [character]
#' @param suffix [character] default is "List"
#' @param contains [character] class name.
#' @param where environment.
#' @return S4 class constructor
setListClass <- function(elementType = NULL, suffix = "List",
                         contains = NULL, where = topenv(parent.frame())){
    stopifnot(is.character(elementType))
    name <- paste0(elementType, suffix)
    setClass(name, contains = c("SimpleList", contains), where = where,
             prototype = prototype(elementType = elementType))
    setMethod("show", name, function(object){
        if(length(object)){
            for(i in 1:length(object)){
                message("[[", i, "]]")
                show(object[[i]])
            }
        }
    })
    ## constructor
    function(...){
        listData <- .dotargsAsList(...)
        S4Vectors:::new_SimpleList_from_list(name, listData)
    }
}



## Function from IRanges
.dotargsAsList <- function(...) {
    listData <- list(...)
  if (length(listData) == 1) {
      arg1 <- listData[[1]]
      if (is.list(arg1) || is(arg1, "List"))
        listData <- arg1
      ## else if (type == "integer" && class(arg1) == "character")
      ##   listData <- strsplitAsListOfIntegerVectors(arg1) # weird special case
  }
  listData
}



## rewrite function call

handle_url2 <- function (handle = NULL, url = NULL, ...) 
{
    if (is.null(url) && is.null(handle)) {
        stop("Must specify at least one of url or handle")
    }
    if (is.null(handle)) 
        handle <- handle_find(url)
    if (is.null(url)) 
        url <- handle$url
    new <- httr:::named(list(...))
    if (length(new) > 0 || is.url(url)) {
        old <- httr::parse_url(url)
        url <- build_url2(modifyList(old, new))
    }
    list(handle = handle, url = url)
}

build_url2 <- function (url) {
    
    stopifnot(httr:::is.url(url))
    scheme <- url$scheme
    hostname <- url$hostname
    if (!is.null(url$port)) {
        port <- paste0(":", url$port)
    }
    else {
        port <- NULL
    }
    path <- url$path
    if (!is.null(url$params)) {
        params <- paste0(";", url$params)
    }
    else {
        params <- NULL
    }
    if (is.list(url$query)) {
        url$query <- httr:::compact(url$query)
        names <- curl_escape(names(url$query))
        values <- as.character(url$query)
        query <- paste0(names, "=", values, collapse = "&")
    }
    else {
        query <- url$query
    }
    if (!is.null(query)) {
        stopifnot(is.character(query), length(query) == 1)
        query <- paste0("?", query)
    }
    if (is.null(url$username) && !is.null(url$password)) {
        stop("Cannot set password without username")
    }
    paste0(scheme, "://", url$username, if (!is.null(url$password)) 
        ":", url$password, if (!is.null(url$username)) 
        "@", hostname, port, "/", path, params, query, if (!is.null(url$fragment)) 
        "#", url$fragment)
}

GET2 <- function (url = NULL, config = list(), ..., handle = NULL) 
{
    hu <- handle_url2(handle, url, ...)
    req <- httr:::request_build("GET", hu$url, config, ...)
    httr:::request_perform(req, hu$handle$handle)
}

POST2 <- function (url = NULL, config = list(), ..., body = NULL, encode = c("multipart", 
    "form", "json"), multipart = TRUE, handle = NULL) 
{
    if (!missing(multipart)) {
        warning("multipart is deprecated, please use encode argument instead", 
            call. = FALSE)
        encode <- if (multipart) 
            "multipart"
        else "form"
    }
    encode <- match.arg(encode)
    hu <- handle_url2(handle, url, ...)
    req <- httr:::request_build("POST", hu$url, httr:::body_config(body, encode), 
        config, ...)
    httr:::request_perform(req, hu$handle$handle)
}



.update_revision <- function(id, revision = NULL){
    if(!is.null(revision)){
        if(grepl("/[0-9]+$", id)){
            res <- gsub("/[0-9]+$", revision, id, perl = TRUE)   
        }else{
            id = gsub("/$", "", id)
            res <- paste0(id, "/", revision)
        }
               
    }else{
        res <- id
    }
    res
}


### lift lift lift!!!

lift.rabix = function(input = NULL, output_dir = NULL, 
                      shebang = "#!/usr/local/bin/Rscript") {
   
    opt_all_list = liftr::parse_rmd(input)
    
    inl <- IPList(lapply(opt_all_list$rabix$inputs, function(i){
        do.call(sevenbridges::input, i)
    }))
    
    ol <- lapply(inl, function(x){
        .nm <- x$inputBinding$prefix
        .t <- setdiff(x$type[[1]], "null")[[1]]
        .type <- paste0('<', deType(.t), '>')
        .o <- paste(.nm, .type, sep = "=")
        .des <- x$description
        .default <- x$default
        if(!is.null(.default)){
            .des <- paste0(.des, " [default: ", .default, " ]")
        }
        list(name = .o, description = .des)
    })
    
   
    if (is.null(output_dir)) 
        output_dir = dirname(normalizePath(input))
    tmp <- file.path(output_dir, opt_all_list$rabix$baseCommand)
    con = file(tmp)
    txt <- c(shebang, "'")
    txt <- c(txt, paste("usage:", opt_all_list$rabix$baseCommand, 
                        do.call(paste,lapply(ol, function(o) paste("[", o$name, "]")))))
    txt <- c(txt, "options:")
    for(i in 1:length(ol)){
        txt <- c(txt, paste(" ", ol[[i]]$name, ol[[i]]$description))
        
    }
    txt <- c(txt, "' -> doc")
    
    
    
    "library(docopt)
    opts <- docopt(doc)
    rmarkdown::render('/report/report.Rmd', BiocStyle::html_document(toc = TRUE),
    output_dir = '.', params = lst)
    " -> .final
    
    txt <- c(txt, .final)
    
    writeLines(txt, con = con)
    close(con)
    
    
    
    ## insert the script
    docker.fl <- file.path(normalizePath(output_dir), 'Dockerfile')
    message(docker.fl)
    
    
    ## add script
    write(paste("COPY", basename(normalizePath(tmp)), "/usr/local/bin/"), 
          file = docker.fl, 
          append = TRUE)
    write("RUN mkdir /report/", 
          file = normalizePath(docker.fl), 
          append = TRUE)
    ## add report
    report.file <- file.path(normalizePath(output_dir), basename(input))
    file.copy(input, report.file)
    write(paste("COPY", basename(input), "/report/"), 
          file = docker.fl, 
          append = TRUE)
    
}


normalizeUrl <- function(x){
    if(!grepl("/$", x)){
        x <- paste0(x, "/")
    }
    x
}


validateApp <- function(req){
    res <- content(req)$raw[["sbg:validationErrors"]]
    if(length(res)){
        message("App pushed but cannot be ran, because it doesn't pass validation")
        lapply(res, function(x) stop(x))
    }
}



.flowsummary <- function(a, id, revision = NULL, includeFile = FALSE){
    ## developed for Andrew : )
    app <- a$app(id = id, revision = revision)
    cwl <- app$raw
    .name <- app$name
    if(cwl$class == "Workflow"){
    .arg <- sum(sapply(cwl$steps, function(x){
        ins <- x$run$input
        if(includeFile){
            length(ins)
        }else{
            idx = sapply(ins, function(i){
                any(sapply(i$type, function(tp){
                    "File" %in% tp 
                }))
            })
            if(sum(idx)){
                length(ins[!idx])
            }else{
                length(ins)
            }
        }
    }))
    .tool <- length(cwl$steps)
    message("name: ", .name)
    message("id: ", id)
    message("Total tool: ", .tool)
    message("Total arguments: ", .arg)
    c('id' = id, 'tool' = .tool, 'arg' = .arg, 'name' = .name)
    }else{
        return(NULL)
    }
}

# res = lapply(x, function(app){
#     id = app$id
#     .flowsummary(a = a, id = id)   
# })

iterId <- function(ids, fun, ...){
    res <- lapply(ids, function(id){
        fun(id = id, ...)
    })
    ## try convert it into a simple list
    .class <- class(res[[1]])
    .newclass <- paste0(.class, "List")
    if(!is.null(tryNew(.newclass,where = topenv(parent.frame())))){
        ## exists
        res <- do.call(.newclass, res)
    }
    res
}

