## 1. how to install hadoop?
1. get hadoop running on docker is pretty easy so you need to have docker installed on linux or wsl on windows (I don't recommend docker desktop)
2. clone this repo into your linux machine
3. make sure your current directory is the directory of this repo
4. ```docker-compose up -d```
5. wait for it and congratulations, hadoop is installed & running. hit http://localhost:9870 to check if hdfs is running and healthy
## 2. how to load data into hadoop?
1. ```./download_data.sh``` to download data into the machine running docker
2. ```./load_data.sh``` to load the data to the namenode container then load it into hdfs
## 3. I know nothing about the structure of the data. what is going on?
this dataset is pulled from https://www.ncei.noaa.gov/data/global-hourly/archive/csv/ so obviously it is hourly weather data in csv files. to understand features and data values themselves they left some pdf files in https://www.ncei.noaa.gov/data/global-hourly/doc/ explaining them
