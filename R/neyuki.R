#' Start/End of long-term snow
#'
#' Calculate long-term snow span from snow-depth vector
#' @param snow snow depth vector (numeric)
#' @param nmin minimum days for long-term snow (int)
#' @param method method for calculation (chr; JMA or none)
#' @return logical
#' @export
neyuki <-
  function(snow, nmin = 10, method = "JMA"){

    if(sum(snow > 0, na.rm = TRUE) == 0){
      usethis::ui_info("No snow!")
    }

    result <- rep(FALSE, length = length(snow))
    seqs <- rle(snow > 0)
    num_sep <- length(seqs$lengths)

    seqs$cumsums <- cumsum(seqs$lengths)
    seqs$more_than_10days <- rep(FALSE, length = num_sep)

    if(isTRUE(seqs$values[1]) || isTRUE(seqs$values[num_sep])){
      # 積雪日から始まった場合、判定が正しくないのでエラー
      usethis::ui_oops("`snow` must start and end with 0 (i.e. no-snow day)")
    }

    # process sequential > nmin-d snow
    for(i in 2:(num_sep-1)){
      if(seqs$values[i] && seqs$lengths[i] >= nmin){
        result[(seqs$cumsums[i-1]+1):seqs$cumsums[i]] <- TRUE
        seqs$more_than_10days[i] <- TRUE
      }
    }

    if(toupper(method) == "JMA"){
      # jma method defines intermittent < 5-d no-snow days between 10-d snow days as neyuki
      for(i in 2:(num_sep-1)){
        if(!seqs$values[i] && seqs$lengths[i] <= 5 && seqs$more_than_10days[i-1] && seqs$more_than_10days[i + 1]){
          result[(seqs$cumsums[i-1]+1):seqs$cumsums[i]] <- TRUE
        }
      }

      if(sum(result) < 30){
        result <- numeric(length(snow))
      }
    }

    return(result)
  }
