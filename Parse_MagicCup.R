Parse_MagicCup<-function(mydir){
  #input: string; path for the csv file of individual participant data
  library(dplyr)
  library(stringr)
  
  raw <- read.csv(mydir)
  #task<-read.csv('magic_cups_spreadsheet.csv') 
  #winloss<-dplyr::select(task,win_1,loss_1,win_2,loss_2)
  #winloss<-na.omit(winloss)
  
  cup <- raw %>% 
    dplyr::select(Participant.Private.ID,UTC.Timestamp,UTC.Date,Local.Timestamp,Local.Date,Local.Timezone, #time and timezone
                  Participant.Device.Type,Participant.Device, Participant.OS, #machine (computer, phone, Mac/Windows/Linux)
                  Participant.Monitor.Size, Participant.Browser, Participant.Viewport.Size, #view from machine
                  #above are subject information; below are trial info (trial type, response, and content)
                  Trial.Number,Screen.Name,Zone.Name,Zone.Type, display, #include all identifiers for trial for future double check
                  Reaction.Time, 
                  Response, Correct, Incorrect, #participant response
                  Attempt, Timed.Out, #quality of trial
                  Image_Left, Image_Right,shape_1, 
                  left_cup, right_cup, win_1,loss_1,win_2,loss_2,
                  first_outcome, sec_outcome,loss_state, win_state, block) %>% 
    filter(str_detect(Zone.Type,"response_button_image") | str_detect(Screen.Name,'Timeout'))
  cup$choices[cup$Response==cup$shape_1]<-1
  cup$choices[is.na(cup$choices)]<-2
  cup$chose1<-cup$choices
  cup$chose1[cup$choices==2]<-0
  cup_condensed<-dplyr::select(cup,choices,chose1,win_1,loss_1,win_2,loss_2)
  return(cup_condensed)
}
