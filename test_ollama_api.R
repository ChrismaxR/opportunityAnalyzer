library(httr2)

# Ollama API documentatie: https://github.com/ollama/ollama/blob/main/docs/api.md

# Testen hoe een call naar Ollama zou kunnen werken
# eerst de curl optie:

# tictoc::tic()
# test_call <- request("http://localhost:11434/api/generate") |>  
#   req_body_raw(
#     "{
#       \"model\": \"llama2\",\n  
#       \"prompt\": \"Which city is the seat of government of Belgium\",\n  
#       \"format\": \"json\",\n  
#       \"stream\": false\n
#     }", 
#     "application/x-www-form-urlencoded") #|>  
#   #req_perform()
# tictoc::toc()

# dan testen met de json body:
# request("http://localhost:11434/api/generate") |>  
#   req_body_json(
#     data = list(
#       model  = "mistral", 
#       prompt = "Which city is the capital of France?", 
#       format = "json",
#       stream = F
#     ),
#     type = "application/json"
#   ) #|> 
#   #req_perform()

#resp_body_json(test_call)


# Geabstraheerd naar een functie ------------------------------------------

ollamaCaller <- function(model, prompt) {
  
  req <- request("http://localhost:11434/api/generate") |>  
    req_body_json(
      data = list(
        model  = model, 
        prompt = prompt, 
        format = "json",
        stream = F
      ),
      type = "application/json"
    ) |> 
    req_perform()
  
  resp <- resp_body_json(req)
  
  # tijden in response zijn in nanoseconden. Om om te rekenen naar seconden, gebruik de divider:
  divider <- 1000000000
  
  # 
  resp_cleaned <- tibble::tibble(
    model = resp$model,
    created_at = resp$created_at,
    response = resp$response,
    total_dur_sec = resp$total_duration/divider,
    load_dur_sec = resp$load_duration/divider, 
    prompt_eval_dur_sec = resp$prompt_eval_duration/divider,
    done = resp$done
  )
  
  return(resp_cleaned)
  
}

# Testen van de functie om performance te checken
test_calls <- purrr::map2_df(
  .f = ollamaCaller, 
  .x = c("llama2", "mistral"),
  .y = c("What is the capital of Germany", "What is the capital of Germany")
)
