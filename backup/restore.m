function restore(file)
% Restore database content from dump file.
%   restore(file) restores the tuples contained in the given .mat file.
%
% AE 2012-11-04

data = load(file);
tables = fieldnames(data);
for i = 1 : numel(tables)
    inserti(eval(['example.' tables{i}]), data.(tables{i}));
    fprintf('Inserted %d tuple(s) into nda.%s\n', numel(data.(tables{i})), tables{i})
end
