FROM node:18

WORKDIR /app

# Copy package files
COPY package.json package-lock.json* ./

# Install dependencies in smaller batches
RUN npm install --no-package-lock --ignore-scripts
RUN npm install --no-package-lock
RUN npm rebuild

# Copy the rest of the application
COPY . .

ENV PORT=3000
EXPOSE $PORT

# Install global dependencies if needed (like vite)
RUN npm install -g vite

CMD ["npm", "run", "dev", "--", "--host", "0.0.0.0"]