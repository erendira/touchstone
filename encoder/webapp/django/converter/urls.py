from django.conf.urls import patterns, include, url
from converter import views

urlpatterns = patterns('',
    url(r'^$', views.converter_index, name='converter_index'),
    #url(r'^$/(?P<status>\w+)/(?P<message>\w+)', views.converter_index, name='converter_index'),
)
