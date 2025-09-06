import { Router } from 'express';
import { listArticles, getArticle, createArticle, updateArticle, deleteArticle } from '../controllers/articleController.js';
const r = Router();

r.get('/articles', listArticles);
r.get('/articles/:id', getArticle);
r.post('/articles', createArticle);
r.put('/articles/:id', updateArticle);
r.delete('/articles/:id', deleteArticle);

export default r;
