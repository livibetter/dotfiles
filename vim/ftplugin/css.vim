" CSS Property Sorter Script (:SortCSS to run)
command! -range=% -nargs=* SortCSS :<line1>,<line2>!sortcss.py <f-args>
