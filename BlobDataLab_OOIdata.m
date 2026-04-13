clear
%% 1. Explore and extract data from one year of OOI mooring data
addpath("OOI_StationPapa_FLMB_CTDdata_BlobDataLab/")
%addpath('')
filenamepractice = 'deployment0001_GP03FLMB.nc';

%1a. Use the function "ncdisp" to display information about the data contained in this file
ncdisp(filenamepractice)

%1b. Use the function "ncreadatt" to extract the latitude and longitude
%attributes of this dataset
lat=ncreadatt(filenamepractice,"/", "lat");
lon = ncreadatt(filenamepractice,"/","lon");

%1c. Use the function "ncread" to extract the variables "time" and
%"ctdmo_seawater_temperature"
time=ncread(filenamepractice,"time");
ctdmo_seawater_temp=ncread(filenamepractice, "ctdmo_seawater_temperature");
ctdmo_seawater_pressure  =ncread(filenamepractice, "ctdmo_seawater_pressure");
depth = mean(ctdmo_seawater_pressure);
% Extension option: Also extract the variable "pressure" (which, due to the
% increasing pressure underwater, tells us about depth - 1 dbar ~ 1 m
% depth). How deep in the water column was this sensor deployed?



%% 2. Converting the timestamp from the raw data to a format you can use
% Use the datenum function to convert the "time" variable you extracted
% into a MATLAB numerical timestamp (Hint: you will need to check the units
% of time from the netCDF file.)

ncid=netcdf.open(filenamepractice, "NC_NOWRITE");

netcdf.getAtt(ncid,netcdf.inqVarID(ncid, 'time'),'units'); % seconds since 1900-01-01 0:0:0


newtime=datenum('1900-01-01 0:0:0');

%correcttime = newtime/86400

tt= newtime+(time/86400);


% Checking your work: Use the "datestr" function to check that your
% converted times match the time range listed in the netCDF file's
% attributes for time coverage

testTime = datenum("2014-06-17 23:45:01");

% 2b. Calculate the time resolution of the data (i.e. long from one
% measurement to the next) in minutes. Hint: the "diff" function will be
% helpful here.
timeresolution = diff(time);
timeresoltuionmin = timeresolution/60;
%% 3. Make an initial exploration plot to investigate your data
% Make a plot of temperature vs. time, being sure to show each individual
% data point. What do you notice about the seasonal cycle? What about how
% the variability in the data changes over the year?
% Hint: Use the function "datetick" to make the time show up as
% human-readable dates rather than the MATLAB timestamp numbers
figure (1); clf
subplot(2,1,1);
plot(tt, ctdmo_seawater_temp,"b--")
datetick('x','mmmyy')
xlabel('Months')
ylabel('Seawater Temperature C')
title('Seawater Temperature vs Time')
hold on
%% 4. Dealing with data variability: smoothing and choosing a variability cutoff
% 4a. Use the movmean function to calculate a 1-day (24 hour) moving mean
% to smooth the data. Hint: you will need to use the time period between
% measurements that you calculated in 2b to determine the correct window
% size to use in the calculation.

OneDay_Smooth= movmean(ctdmo_seawater_temp,96); 

% 4b. Use the movstd function to calculate the 1-day moving standard
% deviation of the data.

OneDaySTD_Smooth = movstd(ctdmo_seawater_temp,96);
%% 5. Honing your initial investigation plot
% Building on the initial plot you made in #3 above, now add:
%5a. A plot of the 1-day moving mean on the same plot as the original raw data

plot(tt,OneDay_Smooth,"r--",'LineWidth',2)
legend({'Sea Temp','One-Day Moving Mean of Sea Temp'})

%hold on

%5b. A plot of the 1-day moving standard deviation, on a separate plot
%underneath, but with the same x-axis (hint: you can put two plots in the
%same figure by using "subplot" and you can specify
subplot(2,1,2);
plot(tt,OneDaySTD_Smooth,"k--")
title("One Day Moving Standard Deviation of Seawater Temperature")
xlabel('Months')
ylabel('Seawater Temperature Standard Deviation C')
datetick('x','mmmyy')
hold on

%% 6. Identifying data to exclude from analysis
% Based on the plot above, you can see that there are time periods when the
% data are highly variable - these are time periods when the raw data won't
% be suitable for use to use in studying the Blob.

%6a. Based on your inspection of the data, select a cutoff value for the
%1-day moving standard deviation beyond which you will exclude the data
%from your analysis. Note that you will need to justify this choice in the
%methods section of your writeup for this lab.

% excluding august to october, basically when STD is greater than 11

%6b. Find the indices of the data points that you are not excluding based
%on the cutoff chosen in 6a.

cutoffid = find(OneDaySTD_Smooth < 0.4);
finalSTDValues = OneDaySTD_Smooth(cutoffid);
finalTT = tt(cutoffid);

%6c. Update your figure from #5 to add the non-excluded data as a separate
%plotted set of points (i.e. in a new color) along with the other data you
%had already plotted.
plot(finalTT,finalSTDValues,"m--")
legend({'One-Day Moving Mean of Sea Temp STD','One-Day Moving Mean of Sea Temp STD with Cutoff at 0.4'})
hold off


%% 7. Apply the approach from steps 1-6 above to extract data from all OOI deployments in years 1-6
% You could do this by writing a for-loop or a function to adapt the code
% you wrote above to something you can apply across all 5 netCDF files
% (note that deployment 002 is missing)z

filename= ["deployment0001_GP03FLMB.nc"; "deployment0003_GP03FLMB.nc" ;"deployment0004_GP03FLMB.nc"; "deployment0005_GP03FLMB.nc" ;"deployment0006_GP03FLMB.nc"]

%bellow is wrong
% for x=1:length(filename)
%     %filename = char("deployment000" + int2str(x) +"_GP03FLMB.nc");
% 
%     lat=ncreadatt(filename(x),"/", "lat");
%     lon = ncreadatt(filename(x),"/","lon");
%     time=ncread(filename(x),"time");
%     ctdmo_seawater_temp=ncread(filename(x), "ctdmo_seawater_temperature");
%     ncid=netcdf.open(filename(x), "NC_NOWRITE");
%     netcdf.getAtt(ncid,netcdf.inqVarID(ncid, 'time'),'units'); % seconds since 1900-01-01 0:0:0
%     newtime=datenum('1900-01-01 0:0:0');
%     tt= newtime+(time/86400);
%     timeresolution = diff(time);
%     timeresoltuionmin = timeresolution/60;
% 
% 
% 
%     figure (x); clf
%     subplot(2,1,1);
%     plot(tt, ctdmo_seawater_temp,"b--")
%     datetick('x','mmmyy')
%     xlabel('Months')
%     ylabel('Seawater Temperature C')
%     title('Seawater Temperature vs Time')
%     hold on
% 
%     OneDay_Smooth= movmean(ctdmo_seawater_temp,96);
%     OneDaySTD_Smooth = movstd(ctdmo_seawater_temp,96);
%     plot(tt,OneDay_Smooth,"r--",'LineWidth',2)
% 
%     subplot(2,1,2);
%     plot(tt,OneDaySTD_Smooth,"k--")
%     xlabel('Months')
%     ylabel('Seawater Temperature Standard Deviation C')
%     datetick('x','mmmyy')
%     hold on
%     cutoffid = find(OneDaySTD_Smooth < 0.4);
%     finalSTDValues = OneDaySTD_Smooth(cutoffid);
%     finalTT = tt(cutoffid);
% 
%     plot(finalTT,finalSTDValues,"m--")
%     hold off
% end

%%


a=length(ncread(filename(1),"time"));
b=length(ncread(filename(2),"time"));
c=length(ncread(filename(3),"time"));
d=length(ncread(filename(4),"time"));
e=length(ncread(filename(5),"time"));
sum_time_length=a+b+c+d+e;

%making empty tt_full array
tt_full=NaN(182694,1);

tt_full(1:a,1)= ncread(filename(1),'time');
tt_full((a+1):(a+b),1)= ncread(filename(2),'time');
tt_full((a+b+1):(a+b+c),1)= ncread(filename(3),'time');
tt_full((a+b+c+1):(a+b+c+d),1)= ncread(filename(4),'time');
tt_full((a+b+c+d+1):end,1)= ncread(filename(5),'time');

tt_full_convert= newtime+(tt_full/86400);

%% long versino of ctdmo_seawater_temperature 
%same length and stuff can use same size for empty 

%making empty tt_full array
ctdmo_seawater_temp_full=NaN(182694,1);

ctdmo_seawater_temp_full(1:a,1)= ncread(filename(1),'ctdmo_seawater_temperature');
ctdmo_seawater_temp_full((a+1):(a+b),1)= ncread(filename(2),'ctdmo_seawater_temperature');
ctdmo_seawater_temp_full((a+b+1):(a+b+c),1)= ncread(filename(3),'ctdmo_seawater_temperature');
ctdmo_seawater_temp_full((a+b+c+1):(a+b+c+d),1)= ncread(filename(4),'ctdmo_seawater_temperature');
ctdmo_seawater_temp_full((a+b+c+d+1):end,1)= ncread(filename(5),'ctdmo_seawater_temperature');

%% Smooth and Std smooth calculations
    

OneDay_Smooth_full= movmean(ctdmo_seawater_temp_full,96);
OneDaySTD_Smooth_full = movstd(ctdmo_seawater_temp_full,96);


%% Plots
figure (2); clf
    subplot(2,1,1);
    plot(tt_full_convert,ctdmo_seawater_temp_full,"b")
    datetick('x','mmmyy')
    xlabel('Months')
    ylabel('Seawater Temperature C')
    title('Seawater Temperature vs Time')
    hold on

    plot(tt_full_convert,OneDay_Smooth_full,"r",'LineWidth',2)
    legend({'Seawater Temp', 'Smoothed Seawater Temp'}, 'location', 'southwest')
    
    subplot(2,1,2);
    plot(tt_full_convert,OneDaySTD_Smooth_full,"k")
    xlabel('Months')
    ylabel('Seawater Temperature Standard Deviation C')
    datetick('x','mmmyy')
    hold on

    cutoffid_full = find(OneDaySTD_Smooth_full < 0.4);
    finalSTDValues_full = OneDaySTD_Smooth_full(cutoffid_full);
    finalTT_full = tt_full_convert(cutoffid_full);
    plot(finalTT_full,finalSTDValues_full,"m")
    legend({'Smoothed STD of Seawater Temp','Cutoff of Data below 0.4'}, 'Location','northeast')
    hold off

  %%
  %extension 1: depth 
pressure=NaN(182694,1);

pressure(1:a,1)= ncread(filename(1),'ctdmo_seawater_pressure');
pressure((a+1):(a+b),1)= ncread(filename(2),'ctdmo_seawater_pressure');
pressure((a+b+1):(a+b+c),1)= ncread(filename(3),'ctdmo_seawater_pressure');
pressure((a+b+c+1):(a+b+c+d),1)= ncread(filename(4),'ctdmo_seawater_pressure');
pressure((a+b+c+d+1):end,1)= ncread(filename(5),'ctdmo_seawater_pressure');



figure (6); clf
plot(tt_full_convert,pressure)
datetick('x','mmm')
xlabel('Months')
ylabel('Depth (m)')


