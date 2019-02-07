function simple_kml_writer(name,latlon)
%Simple function to make a readable kml function.
header=sprintf('<?xml version="1.0" encoding="UTF-8"?>\n<kml xmlns="http://earth.google.com/kml/2.0">\n<Document>');
footer=sprintf('</Document>\n</kml>');
fid = fopen([name '.kml'], 'wt');
fprintf(fid, '%s \n',header);
for i=1:length(latlon(:,1))
    fprintf(fid, '<Placemark> \n<Point><coordinates>%.18f, %.18f, 0 </coordinates></Point> \n</Placemark>\n', latlon(i,2), latlon(i,1));
end
fprintf(fid, '%s', footer);
fclose(fid)