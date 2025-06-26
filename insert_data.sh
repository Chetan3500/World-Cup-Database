#!/bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.

echo "$($PSQL "TRUNCATE teams, games")"
echo "$($PSQL "ALTER SEQUENCE teams_team_id_seq RESTART with 1")"
echo "$($PSQL "ALTER SEQUENCE games_game_id_seq RESTART with 1")"

# INSERT TEAMS
cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do
  if [[ $YEAR != year ]]
  then
    # get team id
    TEAM_WIN_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")
    if [[ -z $TEAM_WIN_ID ]]
    then
      INSERT_WINNER_TEAMS=$($PSQL "INSERT INTO teams(name) VALUES('$WINNER')")
    fi
    # get opponent team id
    TEAM_OPP_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")
    if [[ -z $TEAM_OPP_ID ]]
    then
      INSERT_OPPONENT_TEAMS=$($PSQL "INSERT INTO teams(name) VALUES('$OPPONENT')")
    fi
  fi
done

cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do
  if [[ $YEAR != year ]]
  then  
    TEAM_WIN_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")
    TEAM_OPP_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")
    SQL="INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) VALUES($YEAR, '$ROUND', $TEAM_WIN_ID, $TEAM_OPP_ID, $WINNER_GOALS, $OPPONENT_GOALS);"
    RESULT=$($PSQL "$SQL")
    if [[ $RESULT == "INSERT 0 1" ]]
    then
      echo $YEAR, $ROUND, $TEAM_WIN_ID, $TEAM_OPP_ID, $WINNER_GOALS, $OPPONENT_GOALS
    else
      echo ERR
    fi
  fi
done