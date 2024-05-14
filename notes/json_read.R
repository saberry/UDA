json_files <- list.files("~/Downloads/BioguideProfiles", 
                         all.files = TRUE, 
                         full.names = TRUE, 
                         pattern = ".json")

output <- purrr::map_df(json_files, ~{
  tryCatch({
    input <- read_json(.x, 
                       simplifyDataFrame = TRUE, 
                       flatten = TRUE)
    
    last_year <- length(input$jobPositions$congressAffiliation.congress.endDate)
    
    output <- data.frame(
      profile = input$profileText, 
      party = input$jobPositions$congressAffiliation.partyAffiliation[[1]]$party.name, 
      end_date = input$jobPositions$congressAffiliation.congress.endDate[last_year]
    )
    
    return(output)
  }, 
  error = function(e){
    data.frame(profile = NA, 
               party = NA, 
               end_date = NA)
  })
  
})


