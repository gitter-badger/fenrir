# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# app/assets/javascripts/posts.js.coffee

$(document).ready ->
  $("#posts .page").infinitescroll
    navSelector: "nav.pagination" # selector for the paged navigation (it will be hidden)
    nextSelector: "nav.pagination a[rel=next]" # selector for the NEXT link (to page 2)
    itemSelector: "#posts tr.post" # selector for all items you'll retrieve

$('#myTable01').fixedHeaderTable({ width: 100, height: 1000, footer: true, cloneHeadToFoot: true, altClass: 'odd', autoShow: false });

$('#myTable01').fixedHeaderTable('show', 100);