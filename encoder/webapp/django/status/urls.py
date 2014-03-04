from django.conf.urls import patterns, include, url
from status import views

urlpatterns = patterns('',
    url(r'^$', views.status_index, name='status_index'),
)
