from django.conf.urls import patterns, include, url
from converter import views

urlpatterns = patterns('',
    url(r'^$', views.converter_index, name='converter_index'),
)
